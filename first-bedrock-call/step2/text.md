# Invoke a Model

Now the real thing: send a request and get a completion back. An invoke call has two essential parts — the **`--model-id`** (who to ask) and the **`--body`** (what to ask + how).

### 1. Build the request body

The body is a small JSON file: your **prompt** plus **inference parameters**. Create it:

```
cd /root/bedrock
cat > body.json <<'JSON'
{
  "prompt": "Explain AWS Bedrock in one sentence.",
  "max_tokens": 200,
  "temperature": 0.7
}
JSON
```{{exec}}

Look at what you just wrote:
- **`prompt`** — what you're asking the model.
- **`max_tokens`** — the maximum length of the answer.
- **`temperature`** — `0.7` = a balanced mix of focused and creative.

### 2. Invoke the model

Call the Bedrock runtime. The output is written to `out.json` (the last argument), using the model you chose in Step 1:

```
aws bedrock-runtime invoke-model \
  --model-id "$(cat /root/bedrock/model.txt)" \
  --body file://body.json \
  --cli-binary-format raw-in-base64-out \
  out.json
```{{exec}}

> The `--cli-binary-format` flag is exactly what the real AWS CLI needs for `invoke-model`, so the **command** matches production. (The request **body** here is a simplified teaching shape — real models like Claude use a richer `messages` format.)

### 3. Read the response

```
cat out.json
```{{exec}}

You'll see the model's **`completion`** (the generated text), a **`stop_reason`**, which **`model`** answered, and a **`usage`** block (token counts — what real Bedrock bills on). This is the shape of every LLM response you'll work with.

---

### ✅ Your task

You've made a real invoke call and written `out.json` with a `completion` field. Click **Check**.
