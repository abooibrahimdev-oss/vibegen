# See the Problem

First, check the current GPU status:

```
nvidia-smi
```{{exec}}

Look at two key columns:

- **GPU-Util** — how busy the GPU is
- **Pwr:Usage/Cap** — power draw vs capacity (118W of 700W)

The GPU is barely used and its power draw is far below capacity. This is the classic symptom of a **starving GPU**: the GPU is healthy and powerful, but there isn't **enough work to keep it busy**.

Memory used is 12 GB (so the job *is* running), but compute is nearly idle.

> ⚠️ **Important caveat (and a favourite exam/interview trap):** `nvidia-smi` "GPU-Util" is **the percentage of time at least one kernel was running — not how much of the GPU's compute (SMs) was actually used.** You can read 100% while doing little useful work, and a low number is a *hint*, not proof. The real signals are **DCGM** (SM activity, `dcgm-exporter` → Prometheus/Grafana) and **Nsight** profiling. Here, 25% is a strong starting hint — we'll confirm the cause properly in the next steps.

---

### ✅ Your task

Write down the **GPU-Util** percentage you see (just the number, no `%` sign):

```
echo REPLACE_NUMBER > /root/util.txt
```{{copy}}

Replace `REPLACE_NUMBER` with the utilization value, then run it. Then click **Check**.
