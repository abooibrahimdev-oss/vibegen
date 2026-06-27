# 🎉 The GPU Is Fed!

You just diagnosed and fixed a **starving GPU** — one of the most common (and most expensive) problems in AI infrastructure.

### What you learned
- Low GPU utilization = a **data feeding problem**, not a lack of compute.
- `data_wait >> compute` in the log = the GPU is waiting on data.
- `num_workers` in the data loader should roughly match the number of CPU cores.
- The fix is **not** buying more GPUs — it's fixing the data pipeline.

### Why this skill is valuable
A single H100 can cost hundreds of thousands of dollars. Raising utilization from 25% to 92% means almost **4x more compute value with no new hardware**. This is exactly what companies want from an AI infrastructure engineer.

> 💡 This topic also appears on the **NVIDIA NCA-AIIO** certification (AI Operations & Infrastructure domains).

---

## 📦 Capture your proof
Don't let this evaporate — turn it into portfolio evidence an interviewer can see. Save a short writeup to a GitHub repo or gist:

```
# Diagnosing a Starving GPU
Symptom : GPU-Util 25%, power 118W/700W during ResNet training
Cause   : data loader bottleneck — num_workers=1 on an 8-vCPU node (data_wait >> compute)
Fix     : raised num_workers to 8
Result  : measured GPU-Util 25% -> ~92%, ~3.6x throughput, no new hardware
Caveat  : GPU-Util = kernel-active time, not SM efficiency; confirmed with the benchmark
```

Two lines + your before/after numbers is enough. That's a real story you can tell in an interview.

---

**Next lab:** *"Deploy Your First AI Model on Kubernetes"* — we move up one layer, from hardware to serving. See you there! 🚀
