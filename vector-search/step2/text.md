# Cosine Similarity

You can embed text. Now make it *useful*: given a question, score **every** document and find the closest one. The scoring function is **cosine similarity**.

### The idea in one line

Each embedding is an arrow from the origin. Cosine similarity is the **cosine of the angle between two arrows**:

- same direction -> angle 0° -> cosine **1.0** (as alike as possible)
- unrelated -> angle 90° -> cosine **0.0** (nothing in common)

It uses the *angle*, not the length, so a one-line query and a long paragraph can still be a perfect match. With L2-normalized vectors it's just the dot product — a sum of products, nothing exotic.

### 1. Rank the corpus against a query

`embed rank` embeds your query, scores it against all five Nimbus R7 docs, and sorts them:

```
cd /root/vectors
embed rank "how long does the battery last on a single charge" -o ranked.json
```{{exec}}

`battery.txt` shoots to the top with a high score; the docs about warranty, returns, weight, and wifi sit at or near `0.00`. The retriever found the right document **by geometry alone** — no rules, no keywords you wrote by hand.

### 2. Look at the saved ranking

```
cat ranked.json
```{{exec}}

That's the same data your code would consume: a list of `{id, score}`, already sorted best-first. A program can now grab `ranked[0]` and know exactly which document to trust.

> 💡 This is why it's called *vector search*: you're not matching strings, you're finding the **nearest neighbor** in vector space. Real systems do this over millions of documents in milliseconds using a vector database — but the score being computed is this same cosine.

---

### ✅ Your task

Produce the ranking in `/root/vectors/ranked.json` with **`battery.txt` scored highest**, then click **Check**.
