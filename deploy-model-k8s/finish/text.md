# 🎉 Your Model Is Live and Scalable!

You took a "trained model" from a container image to a **running, callable, horizontally-scaled service** on a real Kubernetes cluster.

### What you learned
- **Pod** = where the container runs (disposable). **Deployment** = the manager that keeps N Pods alive. **Service** = the one stable address that load-balances across them.
- Model serving = a **stateless, scalable service**. That's why Kubernetes fits it perfectly.
- **`replicas`** turns one model server into many for more throughput + high availability — and an **HPA** can do it automatically under load.
- **Readiness probes** keep scaling and rollouts safe: no request hits a Pod that isn't ready.
- The same Deployment + Service + replicas pattern serves **Triton / NVIDIA NIM** in production — you swap the image and add a GPU resource limit + a model-weights volume; the skeleton is unchanged.

---

## 📦 Capture your proof

Don't let this evaporate when the terminal closes. Turn it into a portfolio artifact — proof you can serve a model on Kubernetes.

**1. Grab your evidence** (run these and copy the output):

```
kubectl get deploy,svc,endpoints,pods -l app=model-server
CLUSTER_IP=$(kubectl get svc model-server -o jsonpath='{.spec.clusterIP}')
curl -s http://$CLUSTER_IP:80
```{{exec}}

**2. Save it to a public GitHub repo or gist** — commit your `deployment.yaml`, your `service.yaml`, and a `README.md` from this template:

```
# Deploy an AI Model on Kubernetes

Served a model as a scalable K8s service: a Deployment running the model-server
container, a Service load-balancing across replicas, scaled 1 -> 3 for more
inference throughput (up to ~3x; sub-linear in practice). Same pattern used for
Triton / NVIDIA NIM in production.

## Proof
- `deployment.yaml` / `service.yaml` (in this repo)
- `kubectl get deploy,svc,endpoints,pods`:
  <paste the output here - should show 3/3 ready replicas + 3 endpoints>
- Live prediction returned by the Service:
  {"label":"cat","confidence":0.97}
```{{copy}}

Two lines of writeup + your YAML + the `kubectl get` output + the prediction response = a credible "I can deploy and scale model serving on Kubernetes" sample. Recruiters and teammates can read it in 30 seconds.

> 💡 This builds directly on the certs: Deployments, Services, replicas, and autoscaling are core to the **Kubernetes CKAD/CKA** exams and the **NVIDIA NCA-AIIO** (AI Operations & Infrastructure) domains.

---

**Next up — start the Applied AI Builder track:** *"Your First Bedrock Call"* — you've learned to *serve* models; now learn to *build with* them. Same skeleton you just used carries straight over to serving a real Triton/NIM model on a GPU once that lab ships. See you there! 🚀
