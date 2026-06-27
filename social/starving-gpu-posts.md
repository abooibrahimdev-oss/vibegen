# Launch posts — The Starving GPU (lab #1)

The lesson + diagram double as the marketing. Pair each post with `starving-gpu/assets/pipeline.png`.
Written in English (LinkedIn / X). For IG + Threads (Bahasa, ID audience) — localize with a native pass; don't auto-translate.

---

## LinkedIn (English — professional, your global lane)

A $40,000 GPU running at 25%.

That's not a hardware problem. It's a feeding problem — and it's one of the most common (and expensive) mistakes in AI infrastructure.

Here's the story I turned into a free, hands-on lab:

A team's training job is "slow." The H100 shows 25% GPU utilization, 118W of a 700W budget. The instinct is to ask for more GPUs. Wrong move.

The GPU isn't weak — it's starving. The CPU data loader (1 worker on an 8-core node) can't prepare batches fast enough, so the GPU finishes, waits, finishes, waits. `data_wait` >> `compute`.

The fix isn't more hardware. It's `num_workers: 1 → 8`. Utilization jumps 25% → ~92%. Almost 4x the compute value, zero new spend.

(One nuance most tutorials skip: `nvidia-smi` GPU-Util measures *time a kernel was active*, not how busy the compute units were. Confirm real efficiency with DCGM / Nsight.)

I built this as a 15-minute browser lab — no GPU, no account, real diagnostic flow. Link in comments.

What's the most expensive "just add more hardware" mistake you've seen?

#AIInfrastructure #MLOps #GPU #MachineLearning

---

## X / Threads (English — punchy)

A $40k H100 running at 25%.

The fix isn't "buy more GPUs." It's one line: `num_workers: 1 → 8`.

25% → 92% utilization. ~4x the value, $0 extra.

Low GPU util is almost always a *feeding* problem, not a compute one.

Built it as a free 15-min hands-on lab 👇

---

## IG carousel (outline — 6 slides, use the diagram on slide 3)

1. **Hook:** "This $40,000 AI chip is only working at 25%. Here's why — and the one-line fix."
2. **The symptom:** nvidia-smi → GPU-Util 25%, power 118W/700W. The instinct: "buy more GPUs." (Wrong.)
3. **The diagram** (pipeline.png): Storage → CPU data loader → GPU. The bottleneck is the prep cook, not the chef.
4. **The diagnosis:** data_wait >> compute = the GPU is waiting on data. num_workers=1 on an 8-core node.
5. **The fix:** num_workers 1 → 8. Util 25% → 92%. ~4x value, no new hardware.
6. **CTA:** "Do it yourself — free 15-min browser lab, no GPU needed. [handle / link]"

---

## Notes
- Always lead with the *story / mistake*, not the product. The lab is the payoff, not the pitch.
- Reuse this exact structure for every lab: symptom → wrong instinct → real cause → cheap fix → "do it yourself."
- Next post sources: `deploy-model-k8s` (scale a model service), `rag-with-claude` (watch an LLM hallucinate, then ground it).
