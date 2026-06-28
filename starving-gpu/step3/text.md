# Fix It & Prove It

This node has **8 vCPUs** (see the comment in the config), but only **1** is used for data loading. That's the root cause.

First, measure the baseline. This runs a small benchmark with **real wall-clock timing** over a *simulated* IO-bound data pipeline (the GPU is simulated; the timing is real):

```
retrain
```{{exec}}

You'll see a genuinely low GPU-Util (~25%) and low throughput. Now fix the config.

### 1. Raise num_workers

A good starting point: match the number of CPU cores available for data loading (8 here).

```
sed -i 's/^num_workers:.*/num_workers: 8/' /root/training/train_config.yaml
```{{exec}}

```
grep num_workers /root/training/train_config.yaml
```{{exec}}

### 2. Re-run the benchmark and watch it climb

```
retrain
```{{exec}}

GPU-Util should jump to **~90%+** with much higher throughput — and `nvidia-smi` now reflects it too:

```
nvidia-smi
```{{exec}}

### 3. See the nuance for yourself (optional but recommended)

This is where juniors stop and seniors keep going. **Before you run the next line, predict:** will 64 workers beat 8? Try **overshooting**:

```
sed -i 's/^num_workers:.*/num_workers: 64/' /root/training/train_config.yaml && retrain
```{{exec}}

Notice util **plateaus** — once the data pipeline already keeps the GPU fed, extra workers add **no further gain**. The GPU is now the bottleneck, not the loader, so throwing more workers at it does nothing. In **real** training it gets *worse* than nothing: too many workers cause RAM blowup, `/dev/shm` contention, and scheduling overhead — **diminishing, then negative, returns.** Put it back to 8:

```
sed -i 's/^num_workers:.*/num_workers: 8/' /root/training/train_config.yaml && retrain
```{{exec}}

> 💡 `num_workers` is only the first knob. The real toolkit also includes **`pin_memory`** (faster host→device copies), **`persistent_workers`**, **`prefetch_factor`** (both already in your config), faster storage / caching, and NVIDIA **DALI** to move decode/augmentation onto the GPU.

---

### ✅ Your task

Get the measured **GPU-Util to ≥ 80%** (set `num_workers: 8` and run `retrain`), then click **Check**.
