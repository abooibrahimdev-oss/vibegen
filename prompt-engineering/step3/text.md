# Show, Don't Tell (few-shot)

You can *describe* the format you want in words — or you can just **show** the model a few examples and let it copy the pattern. Showing is faster and far more reliable. A prompt with examples is called **few-shot**; one with none is **zero-shot**.

Watch how a few `input -> output` demonstrations lock the format exactly.

### 1. Write a few-shot prompt

Build a prompt that gives three labelled examples, then asks for the real review in the same shape:

```
cat > p3.txt <<'EOF'
Classify each customer review as:  sentiment | category | urgency

Review: "Love it, super fast and easy to set up!" -> positive | performance | low
Review: "It stopped charging after a week, totally unusable." -> negative | hardware | high
Review: "Wish the app had a dark mode." -> neutral | feature-request | low
Review:
EOF
cat review.txt >> p3.txt
echo ' ->' >> p3.txt
```{{exec}}

Take a look at the full prompt you built:

```
cat p3.txt
```{{exec}}

### 2. Run it

```
ask -f p3.txt -o out3.txt
```{{exec}}

```
cat out3.txt
```{{exec}}

You get `negative | connectivity | high` — the **exact** `sentiment | category | urgency` shape you demonstrated, no prose, no JSON braces, nothing extra. You never *described* the format in words; the examples did it for you.

> 💡 Few-shot is the most reliable way to pin down a format and a labelling style. It's also how you steer edge cases: add an example of the tricky case you keep getting wrong, and the model follows it. Two or three good examples usually beat a paragraph of rules.

---

### ✅ Your task

Save the few-shot result — in the `sentiment | category | urgency` format — to `/root/prompt/out3.txt`, then click **Check**.
