#!/bin/bash
F=/root/prompt/out3.txt
if [ ! -s "$F" ]; then
  echo "No few-shot result saved yet. Run: ask -f p3.txt -o out3.txt"
  exit 1
fi
# expect the demonstrated pipe format: <sentiment> | <category> | <urgency>
if grep -qiE '^[[:space:]]*(positive|negative|neutral)[[:space:]]*\|[[:space:]]*[a-z-]+[[:space:]]*\|[[:space:]]*(low|medium|high)[[:space:]]*$' "$F"; then
  exit 0
fi
echo "That isn't in the demonstrated 'sentiment | category | urgency' format. Make sure your prompt shows 2-3 examples ending in ' ->', then run: ask -f p3.txt -o out3.txt"
exit 1
