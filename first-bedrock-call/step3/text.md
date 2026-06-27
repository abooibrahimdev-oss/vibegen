# Tune the Call

Same model, same prompt — but the **parameters** change the answer. Let's prove it by shrinking `max_tokens` so the model gets cut off, then re-invoking.

### 1. Lower max_tokens

Change `max_tokens` from `200` to `12` in your body:

```
cd /root/bedrock
sed -i 's/"max_tokens": 200/"max_tokens": 12/' body.json
cat body.json
```{{exec}}

### 2. Re-invoke into a new file

Write the tuned result to `out2.json` so you can compare it with the original:

```
aws bedrock-runtime invoke-model \
  --model-id "$(cat /root/bedrock/model.txt)" \
  --body file://body.json \
  --cli-binary-format raw-in-base64-out \
  out2.json
```{{exec}}

### 3. Compare

```
echo "--- original (max_tokens 200) ---"; cat out.json
echo "--- tuned (max_tokens 12) ---"; cat out2.json
```{{exec}}

See it? The tuned `completion` is **cut off**, and `stop_reason` flipped from `stop` to **`max_tokens`** — the model hit your length cap mid-thought. That single number controls cost and latency: fewer tokens = cheaper and faster, but watch for truncation.

### 4. (Optional) Feel temperature

Temperature controls *creativity*. Try a focused vs. an adventurous setting:

```
cp body.json body_temp.json
sed -i 's/"max_tokens": 12/"max_tokens": 200/; s/"temperature": 0.7/"temperature": 0.1/' body_temp.json
aws bedrock-runtime invoke-model --model-id "$(cat /root/bedrock/model.txt)" --body file://body_temp.json out3.json
cat out3.json
```{{copy}}

> ⚠️ **Heads-up (this is a mock):** the fake CLI echoes `temperature` back but doesn't actually vary the text — so `out3.json` reads the same. On **real** Bedrock the output would change.
>
> 💡 In production: **`max_tokens`** guards length and bill; **`temperature`** trades repeatability for variety (low temp for extraction/classification, higher for brainstorming).

---

### ✅ Your task

Re-invoke with a **changed `max_tokens`** (not 200) and write the result to `/root/bedrock/out2.json`. Then click **Check**.
