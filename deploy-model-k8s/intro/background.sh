#!/bin/bash
# Pre-setup for the "Deploy Your First AI Model on Kubernetes" lab.
# The KillerCoda 'kubernetes-kubeadm-1node' image boots a REAL single-node cluster.
# We just wait for the control plane to be Ready, then best-effort pre-pull the tiny
# stand-in model-server image so 'kubectl apply' reaches Ready in seconds during Step 1.

# Wait for the node to register as Ready (first boot can take ~30-60s).
for i in $(seq 1 60); do
  kubectl get nodes 2>/dev/null | grep -q ' Ready ' && break
  sleep 2
done

# Best-effort pre-pull of the lightweight CPU "model server" (ignore any errors).
crictl pull docker.io/hashicorp/http-echo:0.2.3 >/dev/null 2>&1 || true

exit 0
