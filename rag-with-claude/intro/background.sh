#!/bin/bash
# Set up the "RAG in 15 Minutes with Claude" lab on a plain Ubuntu box.
# Builds a tiny knowledge base of fictional-company facts and a REAL, runnable
# RAG loop in pure Python (stdlib only - no pip installs, no API key).
# The retriever is real (IDF-weighted keyword search); the "Claude" generator is a
# MOCK so the lab runs fully offline. The behaviour difference is the lesson.

mkdir -p /root/kb

# --- knowledge base: facts about a fictional company the model can't know ---
cat > /root/kb/warranty.txt <<'EOF'
Nimbus Robotics - Warranty Policy
The Nimbus R7 home robot ships with a 5-year limited warranty.
The warranty covers manufacturing defects and parts replacement.
Accidental damage is not covered unless Nimbus Care Plus is purchased.
EOF

cat > /root/kb/specs.txt <<'EOF'
Nimbus R7 - Technical Specifications
The Nimbus R7 has a battery life of 18 hours on a single charge.
The Nimbus R7 weighs 4.2 kg and recharges fully in 90 minutes.
It runs on a quad-core Aether-1 chip with 8 GB of memory.
EOF

cat > /root/kb/returns.txt <<'EOF'
Nimbus Robotics - Returns and Refunds
Customers may return a Nimbus R7 within 45 days for a full refund.
The Nimbus R7 must be returned in its original packaging.
Refunds are processed within 10 business days.
EOF

cat > /root/kb/support.txt <<'EOF'
Nimbus Robotics - Customer Support
Nimbus R7 support is available 24/7 by email at support@nimbus.example.
The support team responds to most tickets within 4 hours.
Firmware updates ship on the first Monday of every month.
EOF

# --- the RAG loop: real retriever + mock "Claude" generator (stdlib only) ---
cat > /root/rag.py <<'PYEOF'
#!/usr/bin/env python3
"""A tiny but REAL Retrieval-Augmented Generation (RAG) loop - standard library only.

Two pieces, exactly like a production RAG system:
  1. a RETRIEVER  - finds the most relevant document(s) for a question
  2. a GENERATOR  - an LLM that writes the answer

In a real system the generator is Claude (an API call that needs an API key) and
the retriever uses VECTOR EMBEDDINGS. To keep this lab zero-dependency and offline,
the generator is a small MOCK of Claude and the retriever uses IDF-weighted keyword
overlap. The *behaviour* you observe is the real lesson:

  --no-rag  -> closed book. The model answers from its "prior" and HALLUCINATES.
  (default) -> open book.  The model is handed the retrieved facts and quotes them.

Usage:
  python3 rag.py --no-rag "what is the warranty on the Nimbus R7?"
  python3 rag.py          "what is the warranty on the Nimbus R7?"
"""
import os, sys, re, math, glob

KB_DIR = os.environ.get("KB_DIR", "/root/kb")

STOPWORDS = {
    "the", "a", "an", "is", "are", "was", "were", "of", "on", "in", "to", "for",
    "and", "or", "what", "whats", "how", "much", "many", "long", "do", "does",
    "i", "you", "it", "its", "with", "by", "at", "be", "can", "my", "me", "this",
    "that", "there", "their", "have", "has", "about", "tell", "give",
}


def tokenize(text):
    words = re.findall(r"[a-z0-9]+", text.lower())
    return [w for w in words if w not in STOPWORDS and len(w) > 1]


def load_docs():
    docs = {}
    for path in sorted(glob.glob(os.path.join(KB_DIR, "*.txt"))):
        with open(path) as f:
            docs[os.path.basename(path)] = f.read()
    return docs


# ---------------------------------------------------------------------------
# 1. THE RETRIEVER  (IDF-weighted keyword overlap)
# ---------------------------------------------------------------------------
# Every doc here mentions "Nimbus" and "R7", so those words carry no signal.
# Inverse Document Frequency (IDF) down-weights words that appear everywhere and
# rewards the rare, discriminating word ("warranty", "battery", "return"). This is
# the same intuition behind lexical/BM25 search. (Production usually uses vector
# embeddings instead, which match on meaning rather than exact words.)
def retrieve(question, docs, top_k=1):
    q_terms = set(tokenize(question))
    n_docs = len(docs)
    # IDF for each query term, based on how many docs contain it
    idf = {}
    for term in q_terms:
        df = sum(1 for text in docs.values() if term in text.lower())
        # term absent from every doc -> df 0 -> no signal (we skip it)
        idf[term] = math.log((n_docs + 1) / (df + 1)) if df else 0.0
    scored = []
    for name, text in docs.items():
        low = text.lower()
        score = sum(idf[t] for t in q_terms if t in low)
        scored.append((score, name))
    scored.sort(reverse=True)
    # Only keep hits with real signal. If the best score is ~0, nothing relevant
    # was found - the answer is simply not in the knowledge base.
    hits = [(s, n) for s, n in scored if s > 0.15]
    return hits[:top_k]


# ---------------------------------------------------------------------------
# 2. THE GENERATOR  (a MOCK of Claude)
# ---------------------------------------------------------------------------
# Real call: client.messages.create(model="claude-...", messages=[...]) -> needs an API key.
# Here we fake it so the lab runs offline. The two code paths mirror what a real
# LLM actually does:
#   - no context  -> answer from the model's prior knowledge -> confidently WRONG
#                    for a fictional company it was never trained on (a hallucination)
#   - context     -> ground the answer in the supplied text and quote the fact
HALLUCINATIONS = [
    (("warranty", "guarantee"),
     "The Nimbus R7 comes with a standard 1-year manufacturer warranty."),
    (("battery", "charge", "runtime"),
     "The Nimbus R7 lasts roughly 8 hours on a single charge."),
    (("return", "refund"),
     "You can return the Nimbus R7 within the usual 30-day return window."),
    (("weigh", "weight", "heavy"),
     "The Nimbus R7 weighs about 6 kilograms."),
]


def claude_mock(question, context, use_rag):
    """Stand-in for an Anthropic API call. Returns (answer, grounded)."""
    if not context:
        if use_rag:
            # OPEN BOOK, but the book has nothing on this. A well-built RAG system
            # admits it instead of inventing an answer.
            return ("I couldn't find anything about that in the knowledge base, "
                    "so I won't guess."), False
        # CLOSED BOOK: guess from "prior knowledge".
        ql = question.lower()
        for keys, guess in HALLUCINATIONS:
            if any(k in ql for k in keys):
                return guess, False
        return ("I'm not entirely sure, but the Nimbus R7 most likely follows "
                "typical consumer-electronics norms."), False
    # OPEN BOOK: pick the sentence in the context that best matches the question.
    q_terms = set(tokenize(question))
    best, best_score = None, 0
    for chunk in context.values():
        for sent in re.split(r"(?<=[.!?])\s+|\n", chunk):
            sent = sent.strip()
            if not sent:
                continue
            overlap = len(q_terms & set(tokenize(sent)))
            if overlap > best_score:
                best, best_score = sent, overlap
    if best and best_score > 0:
        src = next(iter(context))
        return ('According to %s: "%s"' % (src, best)), True
    # Retrieval ran but nothing in the docs answers the question.
    return ("I couldn't find that in the knowledge base, so I can't answer it "
            "reliably."), False


# ---------------------------------------------------------------------------
# The RAG loop
# ---------------------------------------------------------------------------
def main():
    args = sys.argv[1:]
    use_rag = True
    if args and args[0] == "--no-rag":
        use_rag = False
        args = args[1:]
    if not args:
        print("usage: python3 rag.py [--no-rag] \"your question\"")
        sys.exit(2)
    question = " ".join(args)

    docs = load_docs()
    context = {}
    retrieved_label = "(none - retrieval disabled)"
    if use_rag:
        hits = retrieve(question, docs)
        if hits:
            context = {name: docs[name] for _, name in hits}
            retrieved_label = ", ".join(
                "%s (score %.2f)" % (name, score) for score, name in hits)
        else:
            retrieved_label = "(none - no relevant document found)"

    answer, grounded = claude_mock(question, context, use_rag)

    print("QUESTION  : %s" % question)
    print("MODE      : %s" % ("open-book (RAG)" if use_rag else "closed-book (no RAG)"))
    print("RETRIEVED : %s" % retrieved_label)
    print("GROUNDED  : %s" % ("yes" if grounded else "NO  <- answer is not backed by a source"))
    print("ANSWER    : %s" % answer)


if __name__ == "__main__":
    main()
PYEOF

echo "Lab ready. Knowledge base in /root/kb, RAG loop in /root/rag.py"
