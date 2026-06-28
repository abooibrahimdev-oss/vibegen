# Going live — publish checklist

Two things ship separately: **(A) the labs → KillerCoda**, and **(B) the platform page → your server**.
Per the build-local rule, these are your explicitly-approved steps. Back up before replacing anything live.

---

## A. Publish the 6 labs to KillerCoda

Live labs (all tested, English, 3-pillar bundles):
| Folder | Scenario | Backend |
|--------|----------|---------|
| `starving-gpu/` | The Starving GPU | ubuntu |
| `deploy-model-k8s/` | Deploy a Model on Kubernetes | kubernetes-kubeadm-1node |
| `first-bedrock-call/` | Your First Bedrock Call | ubuntu |
| `prompt-engineering/` | Prompt Engineering: Same Model, Better Answers | ubuntu |
| `vector-search/` | Vector Search From Scratch | ubuntu |
| `rag-with-claude/` | RAG with Claude | ubuntu |

Steps:
1. Push this folder to your **(already-created, public) GitHub repo** `abooibrahimdev-oss/vibegen`:
   ```bash
   cd ~/Documents/GitHub/killercoda-labs
   git init && git add . && git commit -m "Publish 4 labs"
   git branch -M main
   git remote add origin https://github.com/abooibrahimdev-oss/vibegen.git
   git push -u origin main
   ```
   (The repo is currently empty — this is the first push.)
2. Sign in at **https://killercoda.com** with GitHub → **Profile → GitHub** → connect the repo.
   Each folder with an `index.json` becomes one scenario.
3. Note your KillerCoda **username** — scenarios live at
   `https://killercoda.com/<username>/scenario/<folder>`.
4. **Test each scenario** end to end: run every step, confirm each **Check** passes.
   (Verify the kubernetes backend id against current KillerCoda docs if the K8s lab errors.)

## B. Wire the lab links into the platform page (one line!)

In `vibegen/index.platform.html`, find:
```js
const KC_BASE = "https://killercoda.com/USERNAME/scenario";
```
Replace **USERNAME** with your KillerCoda username. Done — all four live lab cards now link to their scenarios automatically. (Until you do this, the links safely stay `#`, so nothing is broken pre-publish.)

## C. Deploy the platform page (separate approved session)

- The Vultr box (65.20.90.66) already serves vibegen at root behind Cloudflare.
- **Back up the current site first** (past incident: data was wiped during a destructive change).
- Decide: make `index.platform.html` the new `index.html` (recommended), or host at `/learn`.
- Then deploy the static files. (No backend needed — labs run on KillerCoda, the exam is client-side, email capture is Firebase.)

---

## Pre-flight (do before A/B/C)
- [ ] `chmod +x` is set on every `*.sh` (verify/background scripts)
- [ ] Each `index.json` is valid JSON
- [ ] Skim each `lesson.md` + `finish/text.md` once more
- [ ] Confirm the platform page serves locally (HTTP 200) and the exam sim runs

## Not yet (deferred by design — gate on proof)
- Accounts / "Sign in with Google to save progress" → Phase 2, after deploy shows people show up.
- Paid exam bank + checkout → Phase 3, after the engagement bar is hit.

---

## Product review pass (2026-06-28) — applied

4 persona reviewers ran on the **product** (labs + exam bank), not the page. Fixes applied:
- **starving-gpu:** step1 verify accepts 24–26 (log shows all three); rewrote the "watch it dip @ 64 workers" claim → it *plateaus* (the sim never dips); added a predict-before-you-run beat; fixed the proof template's mislabeled "3.6x throughput" → "~3.7x utilization".
- **deploy-model-k8s:** softened the unhedged "3x throughput" → "up to ~3x, sub-linear in practice" (3 files); qualified "just swap the image" (real GPU serving also needs a `nvidia.com/gpu` limit + model volume); added a non-blocking `kubectl wait` next to the blocking `-w`.
- **first-bedrock-call:** mock response `stop_reason` "stop" → "end_turn" (current Messages-API value); synced step3 copy.
- **Exam bank:** 22 → **32 questions**. Replaced give-away distractors (Q1/Q2/Q15/Q6/Q16); relabeled TensorRT q "AI Ops" → "NVIDIA Stack"; **added 10 Applied-AI/Essential-AI questions** (RAG ×2, Bedrock ×2, embeddings, supervised/unsupervised, overfitting, data-vs-model parallelism, drift) so the RAG + Bedrock labs finally have matching exam coverage. Balance now Essential 34% / Infra 31% / Ops 22% / Stack 13% (was Essential 14%). Softened the "50+ coming soon" results note.
- **README:** added the missing `first-bedrock-call` row.

**Deferred (bigger product redesign, next session):** per-lab learning objectives + prerequisites headers; a capstone lab that fuses RAG + a real Claude call + K8s serving; cross-lab progress tracking / completion badge / certificate (tie to the existing Firestore email capture); one deliberate fix-it-yourself beat in deploy/rag/bedrock; build or stop teasing the fictional "next labs" in the finish files.
