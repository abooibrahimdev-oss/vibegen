# killercoda-labs

Bite-sized, hands-on AI infrastructure labs for KillerCoda.
Format rules: bite-sized · no video · text + image + hands-on + auto-verify.

## Labs
| Folder | Title | Layer |
|--------|-------|-------|
| `starving-gpu/` | The Starving GPU: Why Is an Expensive GPU Only 25% Utilized? | AI infra/ops (NVIDIA) |
| `deploy-model-k8s/` | Deploy Your First AI Model on Kubernetes | Model serving (Kubernetes) |
| `rag-with-claude/` | RAG in 15 Minutes with Claude | Applied AI Builder (Claude) |

---

## Each lab = 3 pillars (rule: text + image + hands-on, NO video)
Every lab ships complete with **reading + diagram + lab**:
```
starving-gpu/
  lesson.md           # TEXT pillar: concept reading (big-picture first), references the image
  assets/
    pipeline.png      # IMAGE pillar: diagram (PNG; used in lesson + lab intro + social)
  index.json          # manifest: title, steps, backend imageid
  intro/
    text.md           # briefing + diagram (../assets/pipeline.png)
    background.sh      # setup: fake nvidia-smi, config, 'retrain' command
  step1/  text.md  verify.sh   # HANDS-ON pillar
  step2/  text.md  verify.sh
  step3/  text.md  verify.sh
  finish/ text.md     # recap + NCA-AIIO tie-in + teaser for next lab
```
- **Image** = PNG, embedded relatively: from a step/intro use `../assets/x.png`; from root use `./assets/x.png`. (SVG is less reliable in the KillerCoda panel — use PNG.)
- `lesson.md` is the full reading; it also doubles as **build-in-public social content** that funnels to the lab. One production, two uses.
- `*.sh` must be executable (`chmod +x`).
- Click-to-run in markdown: `` `cmd`{{exec}} `` (runs in terminal), `` `text`{{copy}} `` (copy only).
- `verify.sh` exit 0 = pass; output is shown on failure.

---

## How to publish to KillerCoda (DEPLOY step — you run this)

> Build is already local. Publishing is a separate step you do when ready.

1. **Create a public GitHub repo** and push this folder:
   ```bash
   cd ~/Documents/GitHub/killercoda-labs
   git init
   git add .
   git commit -m "Add starving-gpu lab"
   git branch -M main
   git remote add origin https://github.com/<username>/killercoda-labs.git
   git push -u origin main
   ```

2. Go to **https://killercoda.com** → sign in with your **GitHub** account.

3. Open **Profile → GitHub** (creator settings) → **connect the repo** `killercoda-labs`.
   KillerCoda reads each folder that has an `index.json` as one scenario.

4. The scenario appears on your profile at roughly:
   `https://killercoda.com/<username>/scenario/starving-gpu`

5. **Test it first**: run the scenario yourself and confirm each **Check** passes.

> Verify the exact UI steps in KillerCoda at the time — the creator menus change occasionally.
> Docs: https://killercoda.com/creators
