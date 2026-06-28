# 🎉 Same Model, Production-Ready Output

You took **one fixed model** from useless to shippable — without touching the model, only the prompt. That's the core skill of building with LLMs.

### What you learned
- **The prompt is the program.** You don't get a better model by re-asking; you get a better answer by prompting better.
- **Be specific** — name the task, focus, and length. Vague-in, vague-out (and specific is cheaper: fewer tokens).
- **Force the format** — demand JSON when code has to read the answer. Structured output is for software.
- **Few-shot** — show 2–3 examples and the model copies the format exactly, every time.
- The fourth lever, **constraints/grounding** (*"say 'I don't know' if it's not in the text"*), is what makes a model trustworthy — and it's the heart of the **RAG** lab.

### Why this skill is valuable
Almost every applied-AI feature — support triage, extraction, classification, agents — is a good prompt wrapped around an API call. Engineers who can make a general model do specific, reliable work are exactly who teams hire to ship AI features.

> 💡 Prompt design, structured output, and grounding appear on applied-AI certs like the **AWS Certified AI Practitioner** and **NVIDIA NCA-AIIO** (Essential AI Knowledge).

---

## 📦 Capture your proof

Turn this into portfolio evidence. Save a short before/after to a GitHub repo or gist:

```
# Prompt Engineering: vague -> reliable (same model)

Vague:    "Tell me about this review"  -> rambling, generic, unusable.
Specific: "Summarize the main complaint in one sentence" -> one tight sentence.
Structured: "Respond ONLY as JSON {sentiment, category, urgency}" -> parseable JSON.
Few-shot:  3 examples of `review -> sentiment | category | urgency` -> exact format, every time.

Lesson: the model never changed. The prompt did. Specificity + structure + examples
turn a general LLM into a dependable component.
```

Paste your three outputs (`out1.txt`, `out2.txt`, `out3.txt`) next to the prompts that produced them — that contrast is a great interview story.

---

**Next lab:** *"RAG in 15 Minutes with Claude"* — add the fourth lever. You'll feed the model your own documents and use a grounding constraint so it answers from real facts instead of guessing. See you there! 🚀
