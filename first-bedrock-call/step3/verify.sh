#!/bin/bash
F=/root/bedrock/out2.json
if [ ! -f "$F" ]; then
  echo "No /root/bedrock/out2.json yet. Re-invoke with a changed max_tokens and write the result to out2.json."
  exit 1
fi
# Prefer a precise JSON check; fall back to grep if python3 is unavailable.
if command -v python3 >/dev/null 2>&1; then
  if python3 - <<'PY' 2>/dev/null
import json, sys
d = json.load(open("/root/bedrock/out2.json"))
mt = d.get("params_echo", {}).get("max_tokens", 200)
sys.exit(0 if (d.get("completion") and mt != 200) else 1)
PY
  then exit 0; fi
else
  if grep -q '"completion"' "$F" && ! grep -q '"max_tokens": 200' "$F"; then exit 0; fi
fi
echo "Not yet. Change max_tokens in /root/bedrock/body.json to something other than 200, then re-invoke writing /root/bedrock/out2.json. Confirm with: cat out2.json"
exit 1
