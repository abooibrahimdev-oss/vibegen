# Text to Vectors

Move into your working folder and look at the corpus you'll be searching — five short facts about the Nimbus R7:

```
cd /root/vectors
```{{exec}}

```
cat corpus/*.txt
```{{exec}}

Before we can *search* this text, we have to turn it into something a computer can compare with math: a **vector** — a fixed-length list of numbers. Turning text into a vector is called **embedding** it.

### 1. Embed a sentence

Run the mock embedder on one sentence and look at what comes back:

```
embed vec "How long does the Nimbus R7 battery last?"
```{{exec}}

You get a **length-256 vector** — the same shape for *any* text you embed. Most of its 256 buckets are `0.00`; only the buckets for the words actually present light up. That sparse fingerprint **is** the embedding. (A real model fills in all 256 with learned values for *meaning*; our stand-in just buckets the words — same shape, simpler math.)

### 2. Predict, then measure

> 🔮 **Before you run the next commands, predict:** of these two sentences, which one is *more similar* to *"The Nimbus R7 battery lasts about 18 hours per charge"* — a sentence about **battery life**, or a sentence about the **warranty**?

`embed sim` embeds two sentences and reports their **cosine similarity** (next step covers the math; for now, higher = more alike):

```
embed sim "The Nimbus R7 battery lasts about 18 hours per charge." "How many hours of battery life does the Nimbus R7 get per charge?"
```{{exec}}

```
embed sim "The Nimbus R7 battery lasts about 18 hours per charge." "The Nimbus R7 has a five-year warranty against defects."
```{{exec}}

The two battery sentences score **far higher** (~0.77) than the battery-vs-warranty pair (~0.43). They share more words, so their vectors point in nearly the same direction. **That is the entire idea of vector search:** similar text -> similar vectors -> high similarity.

> 💡 In this lab "similar" means *shared words*. A real embedding model goes further and scores *"how long does the charge last?"* close to *"battery life,"* with no shared words at all — because it was trained on meaning. Same vectors, same cosine math; only the embedder gets smarter.

---

### ✅ Your task

Save the embedding of any sentence to `/root/vectors/vec.json` so you can see its shape, then click **Check**:

```
embed vec "The Nimbus R7 battery lasts 18 hours on a single charge." -o vec.json
```{{exec}}
