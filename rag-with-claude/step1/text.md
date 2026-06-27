# Ask Without RAG

First, meet the knowledge base — four short documents of facts about the fictional **Nimbus R7**:

```
ls /root/kb && echo "---" && cat /root/kb/warranty.txt
```{{exec}}

`warranty.txt` clearly states the R7 has a **5-year limited warranty**. The model was never trained on this fictional company, so the *only* way it can know that fact is to be shown the document.

Let's prove what happens when it **isn't** shown. Run the question in **closed-book mode** (`--no-rag` disables retrieval entirely) and save the answer:

```
python3 /root/rag.py --no-rag "what is the warranty on the Nimbus R7?" | tee /root/answer_norag.txt
```{{exec}}

Look at the output:

- **RETRIEVED** is `(none)` — no document was looked up
- **GROUNDED** is `NO` — the answer isn't backed by any source
- **ANSWER** confidently says **1-year** — which is **wrong**. The real answer (5 years) is sitting in `warranty.txt`, but the model never saw it.

This is a **hallucination**: the closed-book model can't say "I don't know," so it invents a plausible-sounding default. Confident, fluent, and incorrect.

> 💡 A real LLM does exactly this on facts it was never trained on — your own product, your internal docs, anything newer than its training cutoff.

---

### ✅ Your task

Capture the wrong answer to a file (the command above already did this with `tee`). Click **Check** to confirm the closed-book run was recorded.
