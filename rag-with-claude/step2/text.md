# Add Retrieval

Now ask the **exact same question** — but this time let the retriever do its job. Just drop the `--no-rag` flag and RAG kicks in:

```
python3 /root/rag.py "what is the warranty on the Nimbus R7?" | tee /root/answer_rag.txt
```{{exec}}

Look at what changed:

- **RETRIEVED** now names `warranty.txt` (with a relevance score) — the retriever found the right document
- **GROUNDED** is `yes` — the answer is backed by a source
- **ANSWER** now correctly says **5-year limited warranty**, quoting the document directly

Same model, same question. The only difference is that the retriever **fed it the right context first**. That's the entire idea of RAG.

### How did the retriever pick `warranty.txt`?

Every document mentions "Nimbus" and "R7", so those words are useless for telling documents apart. The retriever down-weights words that appear everywhere (**IDF** — inverse document frequency) and rewards the rare, meaningful word — here, **warranty** — which appears in only one document. Try another:

```
python3 /root/rag.py "how long does the Nimbus R7 battery last?"
```{{exec}}

It retrieves `specs.txt` and grounds the answer in **18 hours** — the discriminating word `battery` pointed straight at the right file.

> 💡 Real systems do this with **vector embeddings** that match on *meaning*, not exact words — so "how long does it run on a charge?" would still find the battery doc. We use keyword scoring here for zero dependencies, but the retrieve-then-ground architecture is identical.

---

### ✅ Your task

Get a **grounded** answer to the warranty question (the first command above did this and saved it to `/root/answer_rag.txt`). Click **Check** — it confirms the saved answer contains the real fact (**5-year**) from the knowledge base.
