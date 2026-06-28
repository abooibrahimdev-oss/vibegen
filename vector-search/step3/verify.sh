#!/bin/bash
F=/root/vectors/topk.json
if [ ! -s "$F" ]; then
  echo "No top-k result saved yet. Run: embed topk \"how long does the battery last on a single charge\" -k 1 -o topk.json"
  exit 1
fi
python3 - "$F" <<'PY'
import json, sys
try:
    d = json.load(open(sys.argv[1]))
except Exception as e:
    print("Not valid JSON yet (%s). Run: embed topk \"...\" -k 1 -o topk.json" % e)
    sys.exit(1)
if not isinstance(d, list) or not d:
    print("top-k is empty. Use the BATTERY query so it returns a real match, e.g.:")
    print('  embed topk "how long does the battery last on a single charge" -k 1 -o topk.json')
    sys.exit(1)
ids = [row.get("id") for row in d]
if "battery.txt" not in ids:
    print("Expected battery.txt in the top-k, got %s. Re-run with the battery query." % ids)
    sys.exit(1)
if not any(row.get("id") == "battery.txt" and row.get("score", 0) > 0.3 for row in d):
    print("battery.txt is present but its score is low. Use a battery-focused query and re-run.")
    sys.exit(1)
sys.exit(0)
PY
