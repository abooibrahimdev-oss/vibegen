# RAG in 15 Minutes with Claude 📚

You're an **Applied AI Builder**. The support team wants a bot that answers questions about their product — the **Nimbus R7**, a fictional home robot the model has never heard of. Ask a plain LLM and it *guesses*. Your job: stop it from guessing by giving it the right document first.

That technique is **Retrieval-Augmented Generation (RAG)** — and you'll build a real, runnable one in pure Python.

![Question -> Retriever -> Knowledge Base -> Claude -> grounded answer](../assets/diagram.png)

In this lab you will:
1. Ask the mock LLM a question with **no retrieval** and watch it hallucinate
2. Add a **retriever** so it answers grounded in a real document
3. Probe **where RAG breaks** — a question whose answer isn't in the knowledge base

> ⚙️ **Note:** this lab runs fully offline on a plain Linux box — **no API key, no pip installs.** The retriever is real (keyword search over real files); the "Claude" generator is a **mock** so you can see the behavior without a network call. The pipeline you build is exactly the real one.

Click **START** to begin.
