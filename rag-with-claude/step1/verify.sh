#!/bin/bash
if grep -qi 'closed-book' /root/answer_norag.txt 2>/dev/null && \
   grep -qiE '1-year|1 year' /root/answer_norag.txt 2>/dev/null; then
  exit 0
else
  echo "Not yet. Run: python3 /root/rag.py --no-rag \"what is the warranty on the Nimbus R7?\" | tee /root/answer_norag.txt"
  echo "(The closed-book answer should be captured to /root/answer_norag.txt - it will hallucinate a 1-year warranty.)"
  exit 1
fi
