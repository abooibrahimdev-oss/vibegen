#!/bin/bash
if grep -qE '^[[:space:]]*1[[:space:]]*$' /root/workers.txt 2>/dev/null; then
  exit 0
else
  echo "Check the 'num_workers:' line in /root/training/train_config.yaml again, then write the number into /root/workers.txt."
  exit 1
fi
