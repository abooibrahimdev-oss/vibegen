#!/bin/bash
F=/root/vectors/vec.json
if [ ! -s "$F" ]; then
  echo "No embedding saved yet. Run: embed vec \"...some sentence...\" -o vec.json"
  exit 1
fi
python3 - "$F" <<'PY'
import json, sys
try:
    d = json.load(open(sys.argv[1]))
except Exception as e:
    print("Not valid JSON yet (%s). Run: embed vec \"...\" -o vec.json" % e)
    sys.exit(1)
vec = d.get("vector")
if not isinstance(vec, list) or len(vec) != 256:
    print("That isn't a length-256 embedding. Re-run: embed vec \"...\" -o vec.json")
    sys.exit(1)
if not any(isinstance(x, (int, float)) and x != 0 for x in vec):
    print("The vector is all zeros -- embed a sentence with real words, then re-run.")
    sys.exit(1)
sys.exit(0)
PY
