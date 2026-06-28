# 🎉 You Built a RAG Loop!

In 15 minutes you built a real Retrieval-Augmented Generation pipeline and proved, hands-on, why it matters.

### What you learned
- A closed-book LLM **hallucinates** confident, wrong answers about facts it never saw.
- **RAG = retriever + generator.** Retrieve the right document, hand it to the model as context, and the answer becomes **grounded** in a real source.
- The retriever is the heart of it — here, **IDF-weighted keyword** scoring; in production, **vector embeddings** that match on meaning.
- RAG only helps if the answer is **in the corpus** and the retriever **finds it**. Out-of-corpus questions should get an honest "I don't know," not a guess.
- The generator here was a **mock** — a real deployment swaps in an actual Claude API call (which needs an API key).

---

## 📦 Capture your proof

Save what you built as portfolio evidence. Pull your three saved runs together and write a two-line takeaway:

```
echo "=== NO RAG (hallucinates) ==="; cat /root/answer_norag.txt; \
echo; echo "=== WITH RAG (grounded) ==="; cat /root/answer_rag.txt; \
echo; echo "=== OUT OF CORPUS (refuses) ==="; cat /root/answer_oos.txt
```{{exec}}

Copy that output into a public GitHub repo or a gist named **`rag-with-claude-proof`**, alongside this template:

```markdown
# RAG in 15 Minutes with Claude

Built a tiny RAG loop (retriever + mock LLM, Python stdlib only).

**What I proved:** without retrieval the model hallucinated a 1-year warranty;
with retrieval it grounded the correct 5-year answer in warranty.txt; and for a
fact outside the knowledge base it refused to guess instead of hallucinating.

**What I'd build next:** swap keyword retrieval for vector embeddings and the mock
for a real Claude call (`client.messages.create`) to ship a "chat with your docs" bot.
```

Two lines of "here's what I shipped and what I'd do next" turns a lab into proof of skill. 🛠️

---

## 🔌 From mock to real Claude

The only piece that was faked is the generator. In production you'd swap `claude_mock(...)` for a real call — same pipeline, real model:

```python
import anthropic
client = anthropic.Anthropic()  # reads ANTHROPIC_API_KEY

context = "\n\n".join(retrieved_docs)   # from your retriever
resp = client.messages.create(
    model="claude-opus-4-8",
    max_tokens=1024,
    system="Answer ONLY from the provided context. If it's not there, say you don't know.",
    messages=[{"role": "user", "content": f"Context:\n{context}\n\nQuestion: {question}"}],
)
print(resp.content[0].text)
```

That `system` instruction is doing real work: it's what makes a grounded model **refuse** out-of-corpus questions instead of hallucinating — the same behavior you saw in Step 3.

### Why this skill is valuable
RAG is how you make a general LLM answer correctly about **your** product, docs, and data without retraining it — the backbone of support bots, internal search, and "chat with your docs." Shipping this loop is a milestone on the **Applied AI Builder** track.

---

🎓 **That's the Applied AI Builder track** — you can call a foundation model and ground it in your own data. The next step is to put it all together.

**Coming next — the Capstone (in build):** *"Chat with Your Docs, Served"* — wrap this exact retrieval loop in a real Claude call and deploy it on Kubernetes (the skeleton from the *Deploy a Model on Kubernetes* lab), so you finish with one deployable service you can show a recruiter.

In the meantime: test yourself on the free **NCA-AIIO exam simulator** at **vibegen.id**, and grab the proof writeup above for your portfolio. 🚀
