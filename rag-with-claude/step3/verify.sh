#!/bin/bash
if grep -qi 'knowledge base' /root/answer_oos.txt 2>/dev/null && \
   grep -qiE "couldn't find|could not find" /root/answer_oos.txt 2>/dev/null; then
  exit 0
else
  echo "Not yet. Run: python3 /root/rag.py \"what is the price of the Nimbus R7?\" | tee /root/answer_oos.txt"
  echo "(Price is in no document, so RAG should refuse to guess - the answer mentions it couldn't find it in the knowledge base.)"
  exit 1
fi
