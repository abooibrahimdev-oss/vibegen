#!/bin/bash
U=$(cat /root/training/.util 2>/dev/null || echo 0)
W=$(grep -E '^num_workers:' /root/training/train_config.yaml 2>/dev/null | awk '{print $2}')
if [ -f /root/.fixed ] && [ "${U:-0}" -ge 80 ] 2>/dev/null && [ "${W:-0}" -ge 4 ] 2>/dev/null; then
  exit 0
else
  echo "Not done yet. Raise num_workers in /root/training/train_config.yaml, then run 'retrain' until the MEASURED GPU-Util is >= 80%."
  exit 1
fi
