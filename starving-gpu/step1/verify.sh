#!/bin/bash
if grep -qE '^[[:space:]]*2[456][[:space:]]*$' /root/util.txt 2>/dev/null; then
  exit 0
else
  echo "Not quite. Look again at the GPU-Util column from 'nvidia-smi', then write the number (without %) into /root/util.txt."
  exit 1
fi
