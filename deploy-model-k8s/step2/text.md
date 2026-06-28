# Expose & Call It

The Pod is running — but its IP is private and changes every time it restarts. Clients need **one stable address**. That's a **Service**: a fixed ClusterIP + DNS name that load-balances requests across all healthy Pods behind it.

### 1. Write the Service

```
cat > service.yaml <<'EOF'
apiVersion: v1
kind: Service
metadata:
  name: model-server
spec:
  selector:
    app: model-server     # send traffic to Pods with this label
  ports:
  - port: 80              # the Service's port
    targetPort: 5678      # the container's port
EOF
```{{exec}}

The **`selector`** is the magic: the Service automatically finds every Pod labeled `app: model-server` — no IPs hard-coded. Apply it:

```
kubectl apply -f service.yaml
```{{exec}}

### 2. Confirm it found your Pod

```
kubectl get endpoints model-server
```{{exec}}

You should see at least one `IP:5678` under `ENDPOINTS`. **Empty endpoints = the Service matched no ready Pod** (usually a label/selector mismatch). Endpoints present = the wiring is correct.

### 3. Call the model for a prediction

Grab the Service's stable ClusterIP and `curl` it — this is a real request through the Service to your Pod:

```
CLUSTER_IP=$(kubectl get svc model-server -o jsonpath='{.spec.clusterIP}')
curl -s http://$CLUSTER_IP:80
```{{exec}}

You should get your prediction back:

```
{"label":"cat","confidence":0.97}
```

🎉 That round-trip — `client -> Service -> Pod -> prediction` — is **exactly** what a production inference call looks like. Swap the echo image for Triton or NIM and the request path is unchanged. (The real server also needs a GPU resource limit and a model volume — but the client-to-Service-to-Pod path you just exercised stays identical.)

> 💡 **Why a Service and not the Pod IP?** Pods are disposable; their IPs change. The Service is the one address that survives Pod restarts, rollouts, and scaling — and it spreads load across every replica for free.

---

### ✅ Your task

Have a **Service named `model-server`** that resolves to **at least one ready endpoint** (you saw an `IP:5678` above), then click **Check**.
