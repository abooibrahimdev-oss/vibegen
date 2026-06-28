# Force the Format

A one-sentence summary is great for a human. But if your **code** has to act on the answer — route the ticket, log the sentiment, page on-call for urgent issues — prose is a nightmare to parse. You need a **shape**.

So demand one. Tell the model exactly which fields you want and to return **only JSON**.

### 1. Ask for structured output

```
{ echo "Extract the sentiment, category, and urgency from this customer review. Respond ONLY as JSON with keys: sentiment, category, urgency. No prose."; cat review.txt; } > p2.txt
ask -f p2.txt -o out2.txt
```{{exec}}

```
cat out2.txt
```{{exec}}

### 2. Prove it's really machine-readable

If it's valid JSON, your code can load it directly. Let's confirm with a real parser:

```
python3 -m json.tool out2.txt
```{{exec}}

No error = it parsed. You now have `{ "sentiment": ..., "category": ..., "urgency": ... }` — fields a program can branch on, instead of a sentence it has to guess at.

> 💡 This is the difference between a *demo* and a *system*. Free text is for humans; **structured output is for software.** In production you'd pair this with schema validation (and many APIs have a dedicated JSON/structured-output mode) so a malformed response is caught, not shipped.

---

### ✅ Your task

Save the model's **valid JSON** response (with `sentiment`, `category`, `urgency`) to `/root/prompt/out2.txt`, then click **Check**.
