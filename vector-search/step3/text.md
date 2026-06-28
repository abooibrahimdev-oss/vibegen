# Top-k Retrieval

Ranking gives you *every* document, scored. But RAG doesn't want all of them — it wants the **handful most worth reading**. That final cut is **top-k**: sort by similarity, keep the best `k`. This is the actual output a retriever hands to the model.

### 1. Retrieve the top match

`embed topk` ranks the corpus and keeps the best `k` (default 2). Ask the battery question and save the result:

```
cd /root/vectors
embed topk "how long does the battery last on a single charge" -k 1 -o topk.json
```{{exec}}

```
cat topk.json
```{{exec}}

You get `battery.txt` and its text — the single most relevant document. **In a RAG pipeline this is exactly what gets stuffed into the model's context** before it answers. You just built the "retrieve" in Retrieval-Augmented Generation.

### 2. The honest part: an off-topic query

A retriever is only trustworthy if it knows when it has **nothing** to offer. Ask the corpus something it can't possibly answer:

```
embed topk "what is the best pizza topping for a party" -k 2
```{{exec}}

Every score is ~0, so top-k returns **nothing** — no Nimbus doc is about pizza, so none point anywhere near the query. That refusal is the whole point: a retriever that returned its least-bad guess here would make RAG ground its answer in an irrelevant document and **hallucinate**. Returning nothing is the correct, safe answer.

> 💡 You've now built the complete retriever: **embed -> cosine -> top-k**, with a real `score > threshold` cutoff so off-topic queries come back empty. This is the black box the RAG lab handed you. Swap the mock embedder for a trained model and you have a production semantic-search engine.

---

### ✅ Your task

Make sure `/root/vectors/topk.json` holds the top-1 result for the battery query — it should contain **`battery.txt`** — then click **Check**.
