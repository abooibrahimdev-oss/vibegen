# Find the Root Cause

> 🧠 **Heuristic:** low GPU utilization is *most often* a **"feeding" problem** — the GPU is starved of data — so that's where an experienced engineer looks first. But it's **not the only cause.** Low util can also come from:
> - **data loading / storage** too slow (our case here), or **non-pinned host→device copies**
> - **small batch size** or CPU-bound augmentation
> - in **distributed/multi-node** training: **NCCL / interconnect stalls** (gradient sync waiting on a slow fabric) — often the real culprit at scale
> - blocking **checkpoint/logging** on the hot path
>
> Don't just "add more GPUs" — that never fixes a feeding problem. Let's confirm which cause it is.

### 1. Check the training log

```
cat /root/training/train.log
```{{exec}}

Compare two numbers on each step:

- `data_wait` — time the GPU spends **waiting for the next data batch**
- `compute` — time the GPU spends **actually computing**

`data_wait` (~0.8s) is far larger than `compute` (~0.2s). The GPU spends ~80% of its time **waiting for data**. That's why util is only 25%.

### 2. Check the training config

```
cat /root/training/train_config.yaml
```{{exec}}

`num_workers` is the number of CPU processes that prepare data for the GPU. Too few, and the CPU can't feed batches as fast as the GPU consumes them — so the GPU waits.

---

### ✅ Your task

What is the current `num_workers` value? Write the number:

```
echo REPLACE_NUMBER > /root/workers.txt
```{{copy}}

Replace, run, then click **Check**.
