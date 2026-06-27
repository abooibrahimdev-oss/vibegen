#!/bin/bash
# Set up the "Starving GPU" lab on a plain Ubuntu box (no physical GPU).
# The GPU is simulated, but the data-pipeline benchmark in Step 3 is REAL
# (real threads, real wall-clock timing) so the numbers actually respond to your fix.

mkdir -p /root/training
echo 25 > /root/training/.util   # current simulated GPU-Util (nvidia-smi reads this)

# --- dynamic fake nvidia-smi: reflects the current /root/training/.util ---
cat > /usr/local/bin/nvidia-smi <<'SMI'
#!/bin/bash
U=$(cat /root/training/.util 2>/dev/null || echo 25)
P=$(awk -v u="$U" 'BEGIN{v=7.94*u-80; if(v<60)v=60; printf "%d", v}')
cat <<INNER
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 550.54.15              Driver Version: 550.54.15      CUDA Version: 12.4       |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|=========================================+========================+======================|
|   0  NVIDIA H100 80GB HBM3        On    | 00000000:1B:00.0 Off   |                    0 |
| N/A   41C    P0            ${P}W / 700W  |  12648MiB / 81559MiB   |     ${U}%      Default |
+-----------------------------------------+------------------------+----------------------+

+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI        PID   Type   Process name                              GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|    0   N/A  N/A     20473      C   python train.py                            12640MiB  |
+-----------------------------------------------------------------------------------------+
INNER
SMI
chmod +x /usr/local/bin/nvidia-smi

# --- training config (the knobs live here) ---
cat > /root/training/train_config.yaml <<'EOF'
# Training job configuration
# NOTE: this node has 8 vCPUs available for data loading.
model: resnet50
batch_size: 256
epochs: 90
dataset: /data/imagenet
num_workers: 1          # CPU processes preparing data for the GPU
pin_memory: false       # page-locked host memory -> faster host->device copies
persistent_workers: false
prefetch_factor: 2      # batches each worker preloads ahead of time
EOF

# --- training log: data_wait >> compute ---
cat > /root/training/train.log <<'EOF'
[epoch 1] step 10  data_wait=0.82s  compute=0.21s  gpu_util=24%
[epoch 1] step 11  data_wait=0.79s  compute=0.22s  gpu_util=26%
[epoch 1] step 12  data_wait=0.85s  compute=0.20s  gpu_util=25%
# data_wait is MUCH larger than compute => the GPU is waiting on data, not short on compute
EOF

# --- REAL micro-benchmark: models a training step (data prep || GPU compute) ---
cat > /root/training/dataload_bench.py <<'PYEOF'
#!/usr/bin/env python3
"""A small data-pipeline benchmark with REAL wall-clock timing over a SIMULATED
IO-bound input pipeline. Each 'batch' is prepared by a pool of `num_workers` workers
(modeled as IO-bound waits, where more workers genuinely help) then 'computed' by the GPU.
NOTE: real CPU-bound decode/augmentation needs PROCESSES - that's why PyTorch's
num_workers spawns processes, not threads. We use threads here only to simulate IO waits,
so the timing is real but the work is simulated."""
import time, threading, queue, os, re

CFG = "/root/training/train_config.yaml"
PREP_T = 0.10      # seconds to prepare one batch (IO/decode), per worker
COMPUTE_T = 0.02   # seconds of GPU compute per batch
N_BATCHES = 60
AVAIL_CORES = 8

def cfg_int(key, default):
    try:
        for line in open(CFG):
            m = re.match(r'\s*%s:\s*(\d+)' % key, line)
            if m: return int(m.group(1))
    except Exception: pass
    return default

def run(workers):
    q = queue.Queue(maxsize=max(2, workers * 2))
    produced = [0]; lock = threading.Lock()
    # too many workers vs cores -> context-switch overhead (diminishing/negative returns)
    overhead = 1.0 + max(0, workers - AVAIL_CORES) * 0.04
    def worker():
        while True:
            with lock:
                if produced[0] >= N_BATCHES: return
                produced[0] += 1
            time.sleep(PREP_T * overhead)   # prepare a batch
            q.put(1)
    threads = [threading.Thread(target=worker, daemon=True) for _ in range(max(1, workers))]
    t0 = time.time()
    for t in threads: t.start()
    compute = 0.0
    for _ in range(N_BATCHES):
        q.get()                              # wait for a prepared batch = data_wait
        c0 = time.time(); time.sleep(COMPUTE_T); compute += time.time() - c0
    wall = time.time() - t0
    return compute / wall * 100.0, N_BATCHES / wall, wall

def main():
    w = cfg_int("num_workers", 1)
    print("Reading %s" % CFG)
    print("num_workers = %d   (node has %d vCPUs available)" % (w, AVAIL_CORES))
    print("Running %d-batch micro-benchmark (REAL timing)...\n" % N_BATCHES)
    util, thr, wall = run(w)
    try: open("/root/training/.util", "w").write(str(int(round(util))))
    except Exception: pass
    bar = "#" * int(util / 5)
    print("  GPU-Util  : %5.1f%%  [%-20s]" % (util, bar))
    print("  Throughput: %5.1f batches/s" % thr)
    print("  Wall time : %4.1fs for %d batches\n" % (wall, N_BATCHES))
    if util >= 80:
        print("[OK] GPU is fed - the data loader keeps up.")
        open("/root/.fixed", "w").write("1")
    else:
        print("[X] GPU starving - the data loader can't supply batches fast enough.")
        if os.path.exists("/root/.fixed"): os.remove("/root/.fixed")
    if w > AVAIL_CORES:
        print("\nNote: num_workers (%d) exceeds the %d vCPUs - extra workers add overhead,"
              " not speed (diminishing/negative returns)." % (w, AVAIL_CORES))
    elif w >= 4 and util >= 80 and w < 8:
        print("\nTip: also try pin_memory / persistent_workers for host->device copy gains.")

if __name__ == "__main__":
    main()
PYEOF

# --- 'retrain' runs the real benchmark ---
cat > /usr/local/bin/retrain <<'EOF'
#!/bin/bash
exec python3 /root/training/dataload_bench.py
EOF
chmod +x /usr/local/bin/retrain
