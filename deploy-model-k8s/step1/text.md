# Deploy the Model

A **Deployment** is how you say to Kubernetes: *"keep N copies of this container running."* It manages **Pods** (where your container actually runs) and brings them back if they die.

### 1. Write the Deployment

This manifest runs our stand-in model server. Read it before you apply it — every line matters:

```
cat > deployment.yaml <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: model-server
  labels:
    app: model-server
spec:
  replicas: 1                     # start with ONE Pod
  selector:
    matchLabels:
      app: model-server           # this Deployment owns Pods with this label
  template:                       # the Pod "recipe"
    metadata:
      labels:
        app: model-server
    spec:
      containers:
      - name: model-server
        image: hashicorp/http-echo:0.2.3   # tiny CPU stand-in for a model server
        args:
          - "-text={\"label\":\"cat\",\"confidence\":0.97}"   # the "prediction"
          - "-listen=:5678"
        ports:
        - containerPort: 5678
        resources:                # requests let an HPA compute CPU% (see Step 3)
          requests:
            cpu: 50m
          limits:
            cpu: 250m
        readinessProbe:           # Pod only gets traffic once this passes
          httpGet:
            path: /
            port: 5678
          initialDelaySeconds: 2
          periodSeconds: 3
EOF
```{{exec}}

- **`replicas: 1`** — one Pod for now (we scale later).
- **`selector` / `labels`** — how the Deployment knows which Pods are "its own".
- **`readinessProbe`** — the Pod reports "I'm ready to serve" before any request reaches it.

### 2. Apply it

```
kubectl apply -f deployment.yaml
```{{exec}}

### 3. Watch it become Ready

```
kubectl get pods -w
```{{exec}}

Wait until the Pod shows `1/1` and `Running` (`READY 1/1` = the readiness probe passed). Press **Ctrl+C** to stop watching.

Check the Deployment's view of the world:

```
kubectl get deploy model-server
```{{exec}}

`READY 1/1` means the desired and ready replica counts match. Your model is running.

> 💡 **Pod vs Deployment:** you never start Pods by hand in production. You declare desired state on the **Deployment**, and it makes reality match — restarting crashed Pods, rolling out new versions, holding the replica count.

---

### ✅ Your task

Get the `model-server` Deployment to **at least 1 ready replica** (`READY 1/1`), then click **Check**.
