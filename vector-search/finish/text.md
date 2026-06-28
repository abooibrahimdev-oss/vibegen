# 🎉 You Built the Retriever Under RAG

You took five plain text files and built a working **semantic retriever** — embeddings, cosine similarity, and top-k — the exact black box that RAG treats as magic. No API key, no vector database, no model download. Just the core machinery, in your hands.

### What you learned
- **Embeddings turn text into coordinates.** Every piece of text becomes a fixed-shape vector, positioned so similar text lands close. Same shape in, same shape out, every time.
- **Cosine similarity measures relevance by angle.** `1.0` = same direction (alike), `0.0` = perpendicular (unrelated). Score the query against every doc and the highest wins.
- **Top-k is the retrieval result** — sort by score, keep the best `k`. That's literally what gets fed to the model in RAG.
- **A good retriever returns nothing when nothing fits.** The off-topic query scored ~0 everywhere and came back empty — the behavior that keeps RAG from grounding on the wrong document.

### Why this skill is valuable
Every semantic search bar, "chat with your docs" feature, and RAG pipeline runs on this loop. The LLM gets the spotlight, but **retrieval quality is most of what makes the answer correct.** Engineers who can reason about embeddings and similarity — instead of treating retrieval as a black box — are the ones who can actually tune and debug a RAG system.

> 💡 Embeddings, vector similarity, and semantic search appear on applied-AI certs like the **AWS Certified AI Practitioner** and **NVIDIA NCA-AIIO** (Essential AI Knowledge).

---

## 📦 Capture your proof

Turn this into portfolio evidence. Save a short write-up to a GitHub repo or gist:

```
# Vector Search From Scratch: the retriever under RAG

Embed:   text -> a fixed-length vector (similar text -> similar vectors).
Score:   cosine similarity ranks every doc against the query by ANGLE, not keywords.
Top-k:   return the closest k docs -- the exact context RAG feeds to the model.
Honest:  an off-topic query ("best pizza topping") scored ~0 everywhere -> returned NOTHING.

Lesson: retrieval is not magic. embeddings + cosine + top-k IS the engine under RAG,
and retrieval quality -- not the LLM -- is most of what makes the answer right.
```

Paste your `ranked.json` next to the off-topic result — the contrast between "battery question finds battery.txt" and "pizza question finds nothing" is a great interview story.

---

**Next lab:** *"RAG in 15 Minutes with Claude"* — now plug this retriever into a generator. You built the part RAG assembles: it takes your top-k documents, stuffs them into the prompt as context, and lets the model answer *from real facts* instead of guessing. This lab was the prerequisite — go see it click into place. 🚀
