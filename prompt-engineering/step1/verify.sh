#!/bin/bash
F=/root/prompt/out1.txt
if [ ! -s "$F" ]; then
  echo "No answer saved yet. Run the specific prompt and save it: ask -f p1.txt -o out1.txt"
  exit 1
fi
WORDS=$(wc -w < "$F")
if [ "$WORDS" -le 35 ] && grep -qiE 'r7|wi-?fi|disconnect|complaint|support' "$F"; then
  exit 0
fi
echo "That looks like the vague/rambling answer ($WORDS words). Ask for ONE sentence focused on the main complaint, e.g.:"
echo '  { echo "Summarize this customer review in ONE sentence, focusing only on the main complaint:"; cat review.txt; } > p1.txt'
echo '  ask -f p1.txt -o out1.txt'
exit 1
