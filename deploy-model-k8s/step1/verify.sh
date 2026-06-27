#!/bin/bash
READY=$(kubectl get deploy model-server -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
if [ "${READY:-0}" -ge 1 ] 2>/dev/null; then
  exit 0
else
  echo "The 'model-server' Deployment isn't ready yet (ready replicas: ${READY:-0})."
  echo "Run:  kubectl apply -f deployment.yaml   then   kubectl get pods -w"
  echo "Wait until the Pod shows 1/1 Running, then click Check."
  exit 1
fi
