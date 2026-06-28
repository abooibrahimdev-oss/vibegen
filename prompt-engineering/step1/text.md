# Be Specific

Move into your working folder and read the customer review you'll be working with:

```
cd /root/prompt
```{{exec}}

```
cat review.txt
```{{exec}}

A prompt is just **instruction + data**. Let's build one the *lazy* way first and see what happens.

### 1. The vague prompt (the wrong way)

Glue a vague instruction onto the review and send it:

```
{ echo "Tell me about this review:"; cat review.txt; } > p1_vague.txt
ask -f p1_vague.txt
```{{exec}}

You get a **rambling, generic essay**. It's not wrong, exactly — it's *useless*. The model had no idea what you actually wanted, so it gave you everything. That's vague-in, vague-out.

### 2. Predict, then fix it

> 🔮 **Before you run the next command, predict:** if you ask for *one specific thing* — the main complaint, in a single sentence — what changes?

Now write a **specific** prompt: name the task, the focus, and the length.

```
{ echo "Summarize this customer review in ONE sentence, focusing only on the customer's main complaint:"; cat review.txt; } > p1.txt
ask -f p1.txt -o out1.txt
```{{exec}}

Same model. One concise, on-target sentence — exactly what you asked for. Look at what you saved:

```
cat out1.txt
```{{exec}}

> 💡 Specificity is the highest-leverage habit in prompting: name the **task**, the **focus**, and the **format/length**. Bonus — shorter, on-target output costs fewer tokens, so it's cheaper and faster too.

---

### ✅ Your task

Produce a **concise** answer (one focused sentence) in `/root/prompt/out1.txt`, then click **Check**.
