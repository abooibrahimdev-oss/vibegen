#!/bin/bash
if grep -qiE '5-year|5 year' /root/answer_rag.txt 2>/dev/null && \
   grep -qi 'warranty.txt' /root/answer_rag.txt 2>/dev/null; then
  exit 0
else
  echo "Not yet. Run: python3 /root/rag.py \"what is the warranty on the Nimbus R7?\" | tee /root/answer_rag.txt"
  echo "(With retrieval on, the grounded answer should quote the 5-year warranty from warranty.txt.)"
  exit 1
fi
