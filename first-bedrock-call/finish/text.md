# 🎉 You Made Your First Bedrock Call!

You just did the thing every AI feature is built on: **pick a model, shape a request, read and tune the response** — through one consistent API.

### What you learned
- A **foundation model** is a pretrained model (Claude, Titan, Llama...) you *call*, not train.
- **Bedrock** gives you **one invoke API** for all of them — swap the `modelId`, keep your code.
- A request = **`--model-id`** + **`--body`** (`prompt` + inference params).
- **`max_tokens`** caps length (and cost); too small = truncation (`stop_reason: max_tokens`). **`temperature`** trades repeatability for creativity.
- **Bedrock vs. self-hosting:** managed + serverless (ship fast, pay per token) vs. running your own GPUs (more control, far more ops).
- Real calls are **authenticated and billed per token** — here it was mocked, so $0.

---

## 📦 Capture your proof

Don't let this evaporate — turn it into a portfolio artifact. **Save your request, your response, and a 2-line writeup** to a public GitHub repo or a Gist. This is exactly the "show your work" proof that gets Applied-AI builders hired.

Grab the two files you created:

```
cat /root/bedrock/body.json /root/bedrock/out2.json
```{{exec}}

Then commit a `bedrock-first-call.md` using this template:

```
# My First Bedrock Call

**Request (body.json):**
```json
{ "prompt": "Explain AWS Bedrock in one sentence.", "max_tokens": 12, "temperature": 0.7 }
```

**Response (out2.json):**
```json
{ "completion": "...", "stop_reason": "max_tokens", "model": "anthropic.claude-3-sonnet..." }
```

**What I learned (2 lines):**
- Bedrock is one invoke API for many foundation models — I only change the modelId.
- max_tokens caps the answer length and the bill; too small truncates it (stop_reason: max_tokens).
```{{copy}}

> Tip: post the same 2-liner as a build-in-public note. One lab → one artifact → one post.

---

## 🔭 Where this fits

This is Lab 1 of **The Vibe Generation — "Applied AI Builder" track**: learn an AI building block, prove it on a real (or faithfully simulated) stack, and ship the proof.

**Real-cloud next step (when you're ready):** install the real AWS CLI, run `aws configure`, request model access in the Bedrock console, and run the *exact same commands* you just learned — only now they bill your account, so mind `max_tokens`.

**Next lab:** *"Ground Your Model: A First RAG Retrieval"* — we stop the model from guessing and feed it your own documents. See you there! 🚀
