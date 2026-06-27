# Going live — publish checklist

Two things ship separately: **(A) the labs → KillerCoda**, and **(B) the platform page → your server**.
Per the build-local rule, these are your explicitly-approved steps. Back up before replacing anything live.

---

## A. Publish the 4 labs to KillerCoda

Live labs (all tested, English, 3-pillar bundles):
| Folder | Scenario | Backend |
|--------|----------|---------|
| `starving-gpu/` | The Starving GPU | ubuntu |
| `deploy-model-k8s/` | Deploy a Model on Kubernetes | kubernetes-kubeadm-1node |
| `first-bedrock-call/` | Your First Bedrock Call | ubuntu |
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
