#!/bin/bash
# Service must exist
if ! kubectl get svc model-server >/dev/null 2>&1; then
  echo "No Service named 'model-server' found."
  echo "Run:  kubectl apply -f service.yaml   then click Check."
  exit 1
fi

# Service must resolve to at least one ready endpoint (proves it's wired to a running Pod)
EP=$(kubectl get endpoints model-server -o jsonpath='{.subsets[*].addresses[*].ip}' 2>/dev/null)
if [ -z "$EP" ]; then
  echo "The Service exists but has NO endpoints - it isn't pointing at a ready Pod."
  echo "Check the selector (app: model-server) matches the Pod labels, and that the Pod is 1/1 Running."
  echo "Then run:  kubectl get endpoints model-server   and click Check."
  exit 1
fi

exit 0
