#!/bin/bash
F=/root/prompt/out2.txt
if [ ! -s "$F" ]; then
  echo "No JSON saved yet. Run: ask -f p2.txt -o out2.txt"
  exit 1
fi
python3 - "$F" <<'PY'
import json, sys
try:
    d = json.load(open(sys.argv[1]))
except Exception as e:
    print("Not valid JSON yet (%s). Ask the model to respond ONLY as JSON with keys sentiment, category, urgency." % e)
    sys.exit(1)
need = {"sentiment", "category", "urgency"}
if not isinstance(d, dict) or not need.issubset({k.lower() for k in d}):
    print("Valid JSON, but it needs the keys: sentiment, category, urgency. Tighten the prompt and re-run.")
    sys.exit(1)
sys.exit(0)
PY
