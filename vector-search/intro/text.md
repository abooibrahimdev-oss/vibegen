# Vector Search From Scratch 🧑‍💻

You're an **Applied AI Builder**. In the RAG lab, a **retriever** handed the model the right document before it answered — and you took that retriever on faith. Today you build it yourself.

Your task: turn a small set of **Nimbus R7** documents into vectors, then, given a question, return the **most relevant document** — using nothing but embeddings and cosine similarity. This is the engine under every RAG pipeline and every "semantic search" bar.

![Text -> embedder -> vectors; cosine similarity ranks them against a query; return the top-k closest](../assets/diagram.png)

In this lab you will:
1. **Turn text into vectors** — embed sentences and watch similar ones produce more-similar vectors
2. **Rank by cosine similarity** — score a query against every document and find the closest
3. **Return top-k** — hand back the best matches, and prove an off-topic query correctly returns nothing

> 🧪 **Note:** this lab is **fully simulated** with a mock `embed` CLI — **no API key, no network, no cost.** The embedder is a deterministic hashed bag-of-words stand-in for a trained model: it matches on shared *words* rather than deep meaning, but the machinery — `embeddings -> cosine similarity -> top-k` — is exactly the real retriever inside RAG. Swapping in a real embedding model is the only upgrade between this and production.

Click **START** to begin.
