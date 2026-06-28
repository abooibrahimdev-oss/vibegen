#!/bin/bash
F=/root/vectors/ranked.json
if [ ! -s "$F" ]; then
  echo "No ranking saved yet. Run: embed rank \"how long does the battery last on a single charge\" -o ranked.json"
  exit 1
fi
python3 - "$F" <<'PY'
import json, sys
try:
    d = json.load(open(sys.argv[1]))
except Exception as e:
    print("Not valid JSON yet (%s). Run: embed rank \"...\" -o ranked.json" % e)
    sys.exit(1)
if not isinstance(d, list) or not d or "id" not in d[0] or "score" not in d[0]:
    print("That isn't a ranking list of {id, score}. Re-run: embed rank \"...\" -o ranked.json")
    sys.exit(1)
# must be sorted best-first and the best doc must be battery.txt with a real score
top = d[0]
if top["id"] != "battery.txt":
    print("Top result is '%s', not battery.txt. Ask about the BATTERY, e.g.:" % top["id"])
    print('  embed rank "how long does the battery last on a single charge" -o ranked.json')
    sys.exit(1)
if not (top["score"] > 0.3):
    print("battery.txt is on top but its score is low (%.3f). Use a battery-focused query and re-run." % top["score"])
    sys.exit(1)
if any(row["score"] > top["score"] for row in d):
    print("Ranking isn't sorted best-first. Re-run: embed rank \"...\" -o ranked.json")
    sys.exit(1)
sys.exit(0)
PY
