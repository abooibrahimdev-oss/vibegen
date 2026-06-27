# Scale for Load

One Pod can only handle so many inference requests at once. The fix isn't a bigger machine — it's **more identical Pods**. Because the model server is **stateless**, every replica is interchangeable, and the Service spreads traffic across all of them automatically.

### 1. Scale the Deployment to 3 replicas

```
kubectl scale deploy model-server --replicas=3
```{{exec}}

That's it — you changed the *desired state*. The Deployment now works to make reality match.

### 2. Watch the new Pods come up

```
kubectl get pods -w
```{{exec}}

You'll see two new Pods appear and move to `1/1 Running` as their readiness probes pass. Press **Ctrl+C** when all three are `Running`.

```
kubectl get deploy model-server
```{{exec}}

`READY 3/3` — three replicas, ready for ~3x the inference throughput, and if one Pod dies the other two keep serving (high availability).

### 3. See the Service now spans all 3

```
kubectl get endpoints model-server
```{{exec}}

Three `IP:5678` entries now — the **same Service**, no config change, automatically load-balancing across all three Pods. Call it again and it still just works:

```
CLUSTER_IP=$(kubectl get svc model-server -o jsonpath='{.spec.clusterIP}')
curl -s http://$CLUSTER_IP:80
```{{exec}}

### 4. The production move: autoscaling (concept)

You scaled by hand. In production you'd attach a **Horizontal Pod Autoscaler (HPA)**:

```
# Conceptual - needs metrics-server; shown for learning, not required to pass:
# kubectl autoscale deploy model-server --min=3 --max=10 --cpu-percent=70
```{{copy}}

The HPA watches a metric (CPU, GPU utilization, or request latency) and **adds or removes replicas automatically** as traffic rises and falls — so you provision capacity only when you actually need it. Same Deployment, same Service; the replica count just becomes dynamic.

> 💡 **This is the scaling story for real model serving too.** A Triton or NIM Deployment behind a Service, fronted by an HPA keyed on GPU utilization, is how teams serve LLMs and vision models at scale.

---

### ✅ Your task

Get the `model-server` Deployment to **3 ready replicas** (`READY 3/3`), then click **Check**.
