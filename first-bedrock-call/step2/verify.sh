#!/bin/bash
F=/root/bedrock/out.json
if [ ! -f "$F" ]; then
  echo "No /root/bedrock/out.json yet. Run the invoke-model command so it writes out.json (the last argument)."
  exit 1
fi
if grep -q '"completion"' "$F" 2>/dev/null; then
  exit 0
fi
echo "out.json exists but has no \"completion\" field. Re-run the invoke-model command with --body file://body.json and out.json as the last argument."
exit 1
