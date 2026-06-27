# See the Models

Before you can call a model, you need to know which models exist and what their IDs are. Bedrock gives you a catalog.

First, move into your working folder:

```
cd /root/bedrock
```{{exec}}

Now list the available foundation models (this uses the mock `aws` CLI — no account, no cost):

```
aws bedrock list-foundation-models
```{{exec}}

You'll see a JSON catalog. Each entry has a **`modelId`** (the exact string you'll dial), a **`providerName`**, and a **`modelName`**. Notice the variety:

- **`anthropic.claude-3-sonnet-...`** — Claude 3 Sonnet (balanced reasoning + speed)
- **`anthropic.claude-3-haiku-...`** — Claude 3 Haiku (fastest, cheapest)
- **`amazon.titan-text-express-v1`** — Amazon Titan Text
- **`meta.llama3-70b-instruct-v1:0`** — Meta Llama 3 (open weights, hosted by Bedrock)
- **`cohere.command-text-v14`** — Cohere Command

The key idea: **the `modelId` is the only thing that changes between models.** Same API, same code — you just dial a different name.

> 💡 In real Bedrock, a model only works if it's **enabled** in your account/region (you request access once in the console). Here, all of them are available.

---

### ✅ Your task

Pick a model to use and save its **`modelId`**. Claude 3 Sonnet is a great default — but you can swap in any ID from the list above:

```
echo "anthropic.claude-3-sonnet-20240229-v1:0" > /root/bedrock/model.txt
```{{copy}}

Run it, then click **Check**.
