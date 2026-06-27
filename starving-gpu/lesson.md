# 📖 Reading: The Starving GPU

> Read this first (~4 min), then jump into the hands-on lab. Concept first, practice second.

![The AI training data pipeline and where the GPU starves](./assets/pipeline.png)

## 🍳 Big picture: the kitchen and the five-star chef

Think of the GPU as a **five-star chef** who is incredibly fast — able to cook hundreds of plates a minute. But even the greatest chef **can't cook if the ingredients haven't reached the counter**.

The one preparing the ingredients is the **CPU data loader** — like the "prep cooks" who fetch ingredients from the pantry (storage), chop, wash, arrange, and hand them to the chef.

The problem in this lab: there is **1 prep cook** serving **1 lightning-fast chef**. The chef finishes a plate, then... waits. Finishes, waits again. The result is a chef working at only **25%** of capacity. Not because the chef is weak — but because **the ingredients arrive too slowly**.

That is a **starving GPU**: an expensive GPU sitting idle not from a lack of power, but because the **data pipeline can't feed it fast enough**.

**The flow:** `Storage (pantry) -> CPU Data Loader (prep cook) -> GPU (chef)`. The bottleneck is at the prep cook.

---

## Now each component, from its own point of view 👇

### 🎮 "I am the GPU (H100)"
I'm the most expensive compute unit in the room — I can cost hundreds of thousands of dollars. I'm measured by **GPU-Util**: the percentage of time I'm actually computing. If my number is 25%, that means 75% of my time I'm **idle, waiting for data**. Don't buy me a friend (a new GPU) — it's pointless if the ingredients still arrive late. **Fix what feeds me.**

### 🧑‍🍳 "I am the CPU Data Loader"
I prepare the data batches for the GPU. My speed is set by `num_workers` — how many CPU processes work in parallel preparing data. If `num_workers=1`, only 1 of (say) 8 CPU cores is used. I become slow, and the GPU waits on me.

### 🎛️ "I am num_workers"
I'm a small number in the config with a big impact. The rule of thumb: **set me roughly equal to the number of CPU cores** available for data loading. Node has 8 cores? Set me to 8. Suddenly the GPU is flooded with data and its utilization jumps.

---

## ⚠️ One caveat before you trust the number
`nvidia-smi` "GPU-Util" is **the percentage of time at least one kernel was running — not how busy the compute units (SMs) actually were.** You can sit at 100% doing little useful work. So treat a low number as a *hint*, then confirm with real signals: **DCGM** (SM activity, `dcgm-exporter` → Prometheus/Grafana) and **Nsight** profiling.

And low util isn't *always* the data loader. Common causes: slow data loading/storage (our case), non-pinned host→device copies, tiny batch size, CPU-bound augmentation, **NCCL/interconnect stalls in distributed training**, or blocking checkpoint/logging. "Feeding" is the *first* suspect, not the only one.

## 🔍 How to diagnose (the core skill)
1. **Look at GPU-Util** (`nvidia-smi`) — a hint, not proof (see caveat above).
2. **Compare `data_wait` vs `compute`** in the log. If `data_wait` is far larger -> the GPU is waiting on data.
3. **Check `num_workers`** (and `pin_memory`, `prefetch_factor`) in the config.
4. **Raise `num_workers`** toward the CPU-core count, re-run, and prove util climbs — but watch for **diminishing/negative returns** when workers exceed cores (overhead, RAM, `/dev/shm`). Next knobs: `pin_memory`, `persistent_workers`, faster storage, and NVIDIA **DALI**.

## 💰 Why this matters
Raising utilization from 25% to 92% means almost **4x more compute value with no new hardware**. For companies renting GPUs by the hour, that's an immediate, large cost saving. This is the core job of an **AI Infrastructure Engineer**.

> 💡 This concept also appears on the **NVIDIA NCA-AIIO** certification (AI Operations & Infrastructure domains).

---

**Got the concept? Move on to the hands-on lab and prove it yourself.** 🚀
