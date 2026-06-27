# Deploy Your First AI Model on Kubernetes 🚀

You trained a model. Now the team needs to **actually use it** — to send it data and get predictions back, reliably, for thousands of requests.

The move that turns a model file into a product: **run it as a scalable service on Kubernetes.**

![Serving a model on Kubernetes: one Service in front of many Pod replicas](../assets/diagram.png)

In this lab you will:
1. **Deploy** a model server and watch Kubernetes bring it to Ready
2. **Expose** it behind a Service and call it for a live prediction
3. **Scale** it to 3 replicas to handle more inference traffic

> ⚙️ **This is real.** You're on an actual single-node Kubernetes cluster. To keep image pulls fast, the "model" is a tiny CPU container (`hashicorp/http-echo`) that returns a prediction `{"label":"cat","confidence":0.97}`. The Deployment / Service / replica pattern is **identical** to what you'd use for a real Triton or NVIDIA NIM model server — you'd just swap the image.

First, confirm the cluster is up:

```
kubectl get nodes
```{{exec}}

Wait until the node shows `Ready` (give it a few seconds on first boot), then click **START**.
