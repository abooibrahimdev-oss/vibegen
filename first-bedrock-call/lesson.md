# 📖 Reading: Your First Bedrock Call

> Read this first (~4 min), then jump into the hands-on lab. Concept first, practice second.

![Calling a foundation model on AWS Bedrock: app -> invoke API -> model -> response](./assets/diagram.png)

## ☎️ Big picture: one phone line to every expert

Imagine a building full of brilliant experts behind closed doors — a poet, a research analyst, a coder, a translator. Each is a **foundation model**: a large model already trained on a huge amount of text, ready to answer almost anything.

You don't want to hire, house, and feed each expert yourself. You just want to **ask them a question and get an answer**. So instead of barging into rooms, you pick up **one phone line** and dial the expert you want by name.

That phone line is **AWS Bedrock**. The "name you dial" is the **modelId**. The "question and how you want it answered" is the **body**. The expert's reply comes back as a **response**.

**The flow:** `Your App -> Bedrock invoke API (modelId + body) -> Foundation Model -> response`.

The beautiful part: it's the **same phone line for every expert**. Want Claude instead of Llama? You don't rewire anything — you just dial a different `modelId`. That is the whole point of Bedrock.

---

## Now each component, from its own point of view 👇

### 🧠 "I am the Foundation Model"
I'm a large pretrained model — Claude, Titan, Llama, Command. I already know how to write, reason, summarize, and code; you don't train me. You send me an instruction and I generate text back. I live on AWS's hardware, not yours — **you never see my GPUs**.

### ☎️ "I am the Bedrock invoke API"
I'm the single, consistent door to all of those models. You call me as `bedrock-runtime invoke-model`. You hand me two essentials and I do the rest:
- **`--model-id`** — *which* expert you want (e.g. `anthropic.claude-3-sonnet-...`).
- **`--body`** — a small JSON blob: your **prompt** plus **inference parameters**.

I route your request to that model, wait for the generation, and write the **response** to your output file. Swap the model-id and the rest of your code stays the same.

### 🎛️ "I am the body (prompt + parameters)"
I'm the JSON you send. My core fields:
- **`prompt`** — what you're actually asking.
- **`max_tokens`** — a cap on how *long* the answer can be. Set me tiny and the reply gets cut off mid-thought (`stop_reason: max_tokens`).
- **`temperature`** — how *adventurous* the model is. Near `0` = focused and repeatable; near `1` = creative and varied.

> ⚠️ **Honest caveat:** each provider's exact body differs slightly (Anthropic uses a messages format, Titan uses `inputText`/`textGenerationConfig`, etc.). This lab uses **one simplified shape** so you learn the *idea* — `modelId + prompt + params -> completion` — without drowning in per-model schemas.

---

## 🆚 Bedrock vs. self-hosting (the decision that matters)
- **Self-hosting** a model = you rent GPUs, download weights, load them, autoscale, patch, and pay for the box **even when idle**. Maximum control, maximum operational burden.
- **Bedrock** = **managed + serverless**. No GPUs to run, no weights to host. You call an API and pay per token used. You trade some control for almost-zero ops.

Rule of thumb: reach for Bedrock (or any managed model API) to **ship fast and validate**. Consider self-hosting later, only when scale, cost-at-volume, data residency, or custom models justify the operational weight.

## 💰 Cost & auth (read before you ever point this at the real cloud)
Real Bedrock calls are **authenticated** (IAM credentials) and **billed per input + output token** against your AWS account. There's no free lunch — a runaway loop is a runaway bill.

> 🧪 **In this lab everything is mocked.** A fake `aws` CLI returns canned-but-realistic responses. **Zero network, zero cost, no account needed** — the **CLI commands are real**, while the **body/response is a simplified teaching shape** (real models differ), so the CLI muscle memory transfers.

## 🔍 The core skill
1. **List** the available models and choose a `modelId` for the job.
2. **Invoke**: build a body (`prompt` + params), call `invoke-model`, read the `completion`.
3. **Tune**: change `max_tokens` / `temperature`, re-invoke, and *observe how the output changes*.

That loop — *pick a model, shape the request, read and tune the response* — is the foundation of every LLM feature you'll ever build.

> 💡 This maps directly to **The Vibe Generation's "Applied AI Builder" track**: ship real AI features, then show your work.

---

**Got the concept? Move on to the hands-on lab and make your first call.** 🚀
