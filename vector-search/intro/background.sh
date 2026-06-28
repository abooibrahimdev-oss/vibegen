#!/bin/bash
# Set up the "Vector Search From Scratch" lab on a plain Ubuntu box.
# There is NO real embedding model and NO network call here. We install a MOCK `embed`
# CLI (python3, stdlib only) that turns text into a deterministic vector, then ranks
# documents by COSINE SIMILARITY. This is the RETRIEVER that the RAG lab treats as a
# black box -- here you build it yourself: embeddings -> cosine -> top-k.

mkdir -p /root/vectors/corpus
cd /root/vectors

# --- a tiny corpus of facts about the Nimbus R7 (same product as the RAG lab) ---
# Each doc is one short paragraph. The retriever's whole job is to pick the right one.
cat > /root/vectors/corpus/battery.txt <<'EOF'
The Nimbus R7 battery lasts 18 hours on a single charge and recharges fully in 90 minutes.
EOF

cat > /root/vectors/corpus/warranty.txt <<'EOF'
The Nimbus R7 ships with a 5-year limited warranty that covers manufacturing defects.
EOF

cat > /root/vectors/corpus/returns.txt <<'EOF'
You can return the Nimbus R7 within 45 days for a full refund in its original packaging.
EOF

cat > /root/vectors/corpus/wifi.txt <<'EOF'
If the Nimbus R7 keeps disconnecting from wifi, update the firmware and restart your router.
EOF

cat > /root/vectors/corpus/weight.txt <<'EOF'
The Nimbus R7 weighs 4.2 kg and runs on a quad-core Aether-1 chip with 8 GB of memory.
EOF

# --- the MOCK `embed` CLI (python3, stdlib only) ---
cat > /usr/local/bin/embed <<'EMBEDEOF'
#!/usr/bin/env python3
"""MOCK embedding + vector-search CLI -- build a retriever for $0, no API key, no network.

A real embedding model turns text into a vector that captures MEANING. To stay offline
and deterministic, this tool fakes the model with a hashed bag-of-words vector: it splits
text into words and adds each word into a fixed-size vector. Texts that share words land
in the same buckets, so they point in a similar direction -- which is exactly what cosine
similarity measures. It's a teaching stand-in for a real model, but the MACHINERY you
build -- embeddings -> cosine similarity -> top-k -- is the real retriever inside RAG.

Subcommands:
  embed vec  "some text" [-o vec.json]        # turn text into a vector (the embedding)
  embed sim  "text A" "text B"                # cosine similarity between two texts (0..1)
  embed rank "a query" [-o ranked.json]       # score the query against every corpus doc
  embed topk "a query" [-k 2] [-o topk.json]  # return the top-k most relevant docs

The corpus lives in $CORPUS_DIR (default /root/vectors/corpus).
"""
import sys, os, re, json, math, hashlib, glob

DIM = 256  # length of every embedding vector (its "shape")
CORPUS_DIR = os.environ.get("CORPUS_DIR", "/root/vectors/corpus")

# Generic filler words carry no meaning, so we drop them before embedding. (The product
# words "nimbus" and "r7" are kept -- they're real content, just shared by every doc.)
STOPWORDS = {
    "the", "a", "an", "is", "are", "was", "were", "of", "on", "in", "to", "for",
    "and", "or", "what", "whats", "how", "much", "many", "long", "do", "does",
    "i", "you", "it", "its", "with", "by", "at", "be", "can", "my", "me", "this",
    "that", "there", "their", "have", "has", "about", "tell", "give", "get", "per",
}


def tokenize(text):
    words = re.findall(r"[a-z0-9]+", text.lower())
    return [w for w in words if w not in STOPWORDS and len(w) > 1]


def bucket(token):
    """Deterministic word -> vector index. Uses md5 (NOT Python's randomized hash())
    so the SAME word always lands in the SAME bucket on every run, every machine."""
    h = hashlib.md5(token.encode()).hexdigest()
    return int(h, 16) % DIM


def embed_text(text):
    """The 'embedding': a hashed bag-of-words term-frequency vector, L2-normalized so
    that cosine similarity is just the dot product."""
    vec = [0.0] * DIM
    for tok in tokenize(text):
        vec[bucket(tok)] += 1.0
    norm = math.sqrt(sum(x * x for x in vec))
    if norm > 0:
        vec = [x / norm for x in vec]
    return vec


def cosine(a, b):
    return sum(x * y for x, y in zip(a, b))


def load_corpus():
    docs = {}
    for path in sorted(glob.glob(os.path.join(CORPUS_DIR, "*.txt"))):
        with open(path) as f:
            docs[os.path.basename(path)] = f.read().strip()
    return docs


def score_corpus(query):
    qv = embed_text(query)
    docs = load_corpus()
    scored = []
    for name, text in docs.items():
        scored.append({"id": name, "score": round(cosine(qv, embed_text(text)), 4),
                       "text": text})
    scored.sort(key=lambda d: d["score"], reverse=True)
    return scored


def sparse_view(vec):
    """A length-256 vector is mostly zeros, so show only the buckets that lit up
    (index:value). That sparse fingerprint IS the embedding."""
    return "  ".join("%d:%.2f" % (i, x) for i, x in enumerate(vec) if x != 0.0)


def cmd_vec(args):
    out = None
    if "-o" in args:
        i = args.index("-o"); out = args[i + 1]; args = args[:i] + args[i + 2:]
    if not args:
        sys.stderr.write("usage: embed vec \"some text\" [-o vec.json]\n"); sys.exit(2)
    text = args[0]
    vec = embed_text(text)
    nonzero = sum(1 for x in vec if x != 0.0)
    print("text  : %s" % text)
    print("dim   : %d   (every embedding has the same shape: a length-%d vector)" % (DIM, DIM))
    print("nonzero buckets: %d of %d   (only the words present light up -- the vector is sparse)" % (nonzero, DIM))
    print("vector (nonzero buckets only):")
    print("  %s" % sparse_view(vec))
    if out:
        json.dump({"text": text, "dim": DIM, "vector": vec}, open(out, "w"), indent=2)
        sys.stderr.write("\n# saved the embedding to %s\n" % out)


def cmd_sim(args):
    if len(args) < 2:
        sys.stderr.write("usage: embed sim \"text A\" \"text B\"\n"); sys.exit(2)
    a, b = args[0], args[1]
    s = cosine(embed_text(a), embed_text(b))
    print("A: %s" % a)
    print("B: %s" % b)
    print("cosine similarity: %.3f   (1.00 = identical direction, 0.00 = nothing in common)" % s)


def cmd_rank(args):
    out = None
    if "-o" in args:
        i = args.index("-o"); out = args[i + 1]; args = args[:i] + args[i + 2:]
    if not args:
        sys.stderr.write("usage: embed rank \"a query\" [-o ranked.json]\n"); sys.exit(2)
    query = args[0]
    scored = score_corpus(query)
    print("query: %s\n" % query)
    print("  rank  score   doc")
    print("  ----  ------  ----------------")
    for n, d in enumerate(scored, 1):
        print("  %4d  %.4f  %s" % (n, d["score"], d["id"]))
    print("\nThe highest-scoring doc is the one whose words point most in the query's direction.")
    if out:
        json.dump([{"id": d["id"], "score": d["score"]} for d in scored],
                  open(out, "w"), indent=2)
        sys.stderr.write("\n# saved the full ranking to %s\n" % out)


def cmd_topk(args):
    out = None; k = 2
    if "-o" in args:
        i = args.index("-o"); out = args[i + 1]; args = args[:i] + args[i + 2:]
    if "-k" in args:
        i = args.index("-k"); k = int(args[i + 1]); args = args[:i] + args[i + 2:]
    if not args:
        sys.stderr.write("usage: embed topk \"a query\" [-k 2] [-o topk.json]\n"); sys.exit(2)
    query = args[0]
    scored = score_corpus(query)
    # Only keep matches with real signal. If the best score is ~0, nothing in the
    # corpus is relevant -- a good retriever returns NOTHING rather than a bad guess.
    hits = [d for d in scored if d["score"] > 0.05][:k]
    print("query: %s\n" % query)
    if not hits:
        print("top-%d: (no relevant documents found -- every score is ~0)" % k)
        print("\nNothing in the corpus is about this. A retriever that returns nothing here")
        print("is what stops RAG from grounding an answer in an irrelevant document.")
    else:
        for d in hits:
            print("  [%.4f] %s" % (d["score"], d["id"]))
            print("          %s" % d["text"])
        print("\nThese are the documents RAG would hand to the model as context.")
    if out:
        json.dump([{"id": d["id"], "score": d["score"], "text": d["text"]} for d in hits],
                  open(out, "w"), indent=2)
        sys.stderr.write("\n# saved the top-%d result to %s\n" % (k, out))


def main():
    argv = sys.argv[1:]
    if not argv or argv[0] in ("-h", "--help"):
        print(__doc__); sys.exit(0)
    cmd, rest = argv[0], argv[1:]
    table = {"vec": cmd_vec, "sim": cmd_sim, "rank": cmd_rank, "topk": cmd_topk}
    if cmd not in table:
        sys.stderr.write("unknown command '%s'. try: vec | sim | rank | topk\n" % cmd)
        sys.exit(2)
    table[cmd](rest)


if __name__ == "__main__":
    main()
EMBEDEOF
chmod +x /usr/local/bin/embed

cat > /root/vectors/README.txt <<'EOF'
This lab uses a MOCK `embed` CLI -- deterministic, no API key, no network, no cost.
It turns text into a vector (a hashed bag-of-words embedding) and ranks documents by
cosine similarity. You are building the RETRIEVER that RAG treats as a black box.
  embed vec  "some text"            # turn text into a vector
  embed sim  "text A" "text B"      # cosine similarity between two texts
  embed rank "a query"              # score the query against every corpus doc
  embed topk "a query" -k 2         # return the top-k most relevant docs
Corpus: /root/vectors/corpus/*.txt  (facts about the Nimbus R7)
EOF

cd /root/vectors
echo "Lab ready. Mock embedder at /usr/local/bin/embed, corpus in /root/vectors/corpus"
