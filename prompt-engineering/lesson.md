# 📖 Reading: Prompt Engineering — Same Model, Better Answers

> Read this first (~4 min), then jump into the hands-on lab. Concept first, practice second.

![A vague prompt yields messy output; an engineered prompt (specific + format + examples) yields clean, reliable output — from the same model](./assets/diagram.png)

## 🧑‍💼 Big picture: the brilliant, over-literal new hire

Imagine a new hire who is brilliant, fast, and has read almost everything — but takes every instruction **literally** and will never ask you a clarifying question. If you say *"tell me about this review,"* they hand you a rambling essay. If you say *"in one sentence, what's the customer's main complaint?"* they nail it.

That's a large language model. You don't make it smarter by asking again. You make it **useful** by writing a better instruction. **The prompt is the program you write for the model** — and prompt engineering is just learning that language.

> Same model. Same question underneath. The only variable that changes the output is **how you ask.**

This matters because the model that powers your feature is fixed — you call it through an API (you saw that in *Your First Bedrock Call*). You can't retrain it. The prompt is the one lever you fully control, and it's the difference between a flaky demo and something you can ship.

---

## The three highest-leverage techniques 👇

You'll practice these three in the lab — they give you most of the gains:

### 🎯 1. Specificity — say exactly what you want
Vague in, vague out. *"Tell me about this review"* invites an essay. *"Summarize the main complaint in one sentence"* gets a usable answer. Name the **task**, the **focus**, and the **length**. Cutting ambiguity is the single biggest win — and shorter, on-target output is also **cheaper and faster** (you pay per token).

### 🧱 2. Structure — force the output into a shape
If your code has to read the answer, don't accept prose — **demand a format**. *"Respond ONLY as JSON with keys `sentiment`, `category`, `urgency`."* Now the output is **parseable**: your program can `json.load` it instead of guessing. Free text is for humans; structured output is for systems.

### 🧩 3. Few-shot — show, don't tell
The fastest way to lock in a format is to **demonstrate it**. Give two or three `input -> output` examples and the model copies the pattern exactly:
```
Review: "Love it, super fast!" -> positive | performance | low
Review: "Stopped charging in a week." -> negative | hardware | high
Review: "<the real one>" ->
```
"Zero-shot" = no examples; "few-shot" = a handful. A few good examples beat a paragraph of instructions almost every time.

---

## 🛡️ The fourth lever: constraints (and where RAG comes in)

The techniques above shape *how* the model answers. **Constraints** govern what it's *allowed* to say — e.g. *"If the answer isn't in the text, say 'I don't know' — do not guess."* That single line is what turns a confident hallucinator into a system you can trust, and it's the bridge to **Retrieval-Augmented Generation**: RAG feeds the model your documents, and the constraint keeps it honest about what those documents actually say. (That's its own lab — *RAG in 15 Minutes with Claude*.)

---

## 🧠 Why this is the whole job

Every applied-AI feature — support bots, extractors, classifiers, agents — is mostly **a good prompt wrapped around an API call**. Get the prompt right and a general model does specific, reliable work. Get it wrong and no amount of GPU saves you.

> 💡 Prompt design, structured output, and grounding all show up in applied-AI certs like the **AWS Certified AI Practitioner** and **NVIDIA NCA-AIIO** (Essential AI Knowledge).

---

**Got the idea? Open the lab and make one fixed model go from useless to production-ready — by changing only the prompt.** 🚀
