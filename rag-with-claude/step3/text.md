# See Where It Breaks

RAG isn't magic. It can only ground an answer in facts that **exist in the knowledge base**. Ask for something that isn't written in any document and watch what happens.

None of the four docs mention **price**. Ask for it *with RAG on*:

```
python3 /root/rag.py "what is the price of the Nimbus R7?" | tee /root/answer_oos.txt
```{{exec}}

Look at the output:

- **RETRIEVED** is `(none - no relevant document found)` — the word `price` appears in zero documents, so the retriever correctly finds nothing
- **GROUNDED** is `NO`
- **ANSWER** honestly says **"I couldn't find anything about that in the knowledge base."**

This is the **good** failure mode: a well-built RAG system would rather admit it doesn't know than invent a number. Compare that to Step 1, where the *closed-book* model happily made up a wrong warranty. RAG didn't give us the price — it can't — but it stopped the model from lying about it.

### The lesson: RAG is only as good as its corpus and its retriever

Two things bound what RAG can do:

1. **Coverage** — if the fact isn't in the knowledge base, no retriever can find it. The fix isn't a better model; it's **adding the document**. Add a price doc and the same question would suddenly work:

   ```
   echo "The price of the Nimbus R7 is 899 USD." > /root/kb/pricing.txt && python3 /root/rag.py "what is the price of the Nimbus R7?"
   ```{{exec}}

   Same question, now grounded in **899 USD** — because the answer finally exists in the corpus.

2. **Retrieval quality** — if the retriever pulls the *wrong* document, the model grounds its answer in the wrong fact and still sounds confident. Better embeddings, smarter chunking, and re-ranking are how production systems keep retrieval sharp.

> ⚠️ "Add RAG" is not a one-and-done fix. Most of the real engineering is in the **knowledge base** (what's in it, how it's chunked) and the **retriever** (does it surface the right passage). The LLM is the easy part.

---

### ✅ Your task

Run the out-of-knowledge-base query above (saved to `/root/answer_oos.txt`). Click **Check** — it confirms the system refused to guess instead of hallucinating.
