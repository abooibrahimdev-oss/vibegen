#!/bin/bash
READY=$(kubectl get deploy model-server -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
if [ "${READY:-0}" -ge 3 ] 2>/dev/null; then
  exit 0
else
  echo "Not 3 ready replicas yet (currently ${READY:-0})."
  echo "Run:  kubectl scale deploy model-server --replicas=3   then   kubectl get pods -w"
  echo "Wait until all 3 Pods show 1/1 Running, then click Check."
  exit 1
fi
