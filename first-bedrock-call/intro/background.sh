#!/bin/bash
# Set up the "Your First Bedrock Call" lab on a plain Ubuntu box.
# There is NO real AWS account and NO network call here. We install a FAKE `aws`
# CLI that imitates two real Bedrock commands so you can learn the request/response
# flow for $0. The CLI command/argument shape matches the real AWS CLI; the request
# body is a simplified teaching shape (real models like Claude use a richer format).

mkdir -p /root/bedrock
cd /root/bedrock

# --- the fake `aws` CLI (python3 for robust JSON handling) ---
cat > /usr/local/bin/aws <<'AWSEOF'
#!/usr/bin/env python3
"""A MOCK of the AWS CLI, scoped to two Bedrock commands. Zero network, zero cost.
Supported:
  aws bedrock list-foundation-models
  aws bedrock-runtime invoke-model --model-id <id> --body <json|file://...> [opts] <outfile>
Real CLI flags like --cli-binary-format / --region / --content-type are accepted and ignored."""
import sys, os, json, hashlib

MODELS = [
    ("anthropic.claude-3-sonnet-20240229-v1:0", "Anthropic", "Claude 3 Sonnet",
     "Balanced reasoning + speed. Great default for chat, RAG, and agents."),
    ("anthropic.claude-3-haiku-20240307-v1:0", "Anthropic", "Claude 3 Haiku",
     "Fastest + cheapest Claude. High-volume classification and extraction."),
    ("amazon.titan-text-express-v1", "Amazon", "Titan Text Express",
     "AWS-native text model. Summarization and open-ended generation."),
    ("meta.llama3-70b-instruct-v1:0", "Meta", "Llama 3 70B Instruct",
     "Open-weights instruct model, hosted and managed by Bedrock."),
    ("cohere.command-text-v14", "Cohere", "Command",
     "Enterprise text generation and retrieval-augmented workloads."),
]

def die(msg, code=255):
    sys.stderr.write("\n" + msg + "\n")
    sys.exit(code)

def list_models():
    try:
        open("/root/bedrock/.listed", "w").write("1")
    except Exception:
        pass
    print("{")
    print('    "modelSummaries": [')
    for i, (mid, prov, name, _desc) in enumerate(MODELS):
        comma = "," if i < len(MODELS) - 1 else ""
        print("        {")
        print('            "modelId": "%s",' % mid)
        print('            "providerName": "%s",' % prov)
        print('            "modelName": "%s",' % name)
        print('            "inputModalities": ["TEXT"],')
        print('            "outputModalities": ["TEXT"],')
        print('            "responseStreamingSupported": true')
        print("        }%s" % comma)
    print("    ]")
    print("}")
    sys.stderr.write("\n# (mock) %d foundation models available. "
                     "Pick a modelId for the next step.\n" % len(MODELS))

def gen_completion(prompt, model_id):
    p = (prompt or "").lower()
    if "bedrock" in p:
        body = ("Amazon Bedrock is a fully managed service that gives you a single API "
                "to call hosted foundation models from providers like Anthropic, Amazon, "
                "Meta and Cohere -- no servers or GPUs for you to run.")
    elif "haiku" in p or "poem" in p:
        body = ("Silent server hums,\nweights awaken in the cloud --\nan answer takes form.")
    elif "difference" in p or "vs" in p or "self-host" in p or "self host" in p:
        body = ("Bedrock is managed and serverless: you call an API and AWS runs the model. "
                "Self-hosting means you provision GPUs, load weights, scale and patch it all "
                "yourself -- more control, far more operational burden.")
    else:
        body = ("Here is a concise, helpful answer to your prompt. Foundation models on "
                "Bedrock turn your instruction into text through one consistent invoke API, "
                "so the same code works across many providers.")
    # tiny per-prompt variation so different prompts read slightly differently
    h = int(hashlib.md5((prompt or "").encode()).hexdigest(), 16) % 3
    tail = ["", " Ask a follow-up to go deeper.", " Adjust the parameters to change this output."][h]
    return body + tail

def invoke(args):
    model_id = None
    body_arg = None
    positionals = []
    flags_with_value = {"--model-id", "--body", "--content-type", "--accept",
                        "--region", "--cli-binary-format", "--profile", "--endpoint-url"}
    i = 0
    while i < len(args):
        a = args[i]
        if a == "--model-id":
            model_id = args[i + 1] if i + 1 < len(args) else None; i += 2; continue
        if a == "--body":
            body_arg = args[i + 1] if i + 1 < len(args) else None; i += 2; continue
        if a in flags_with_value:
            i += 2; continue
        if a.startswith("--"):
            i += 1; continue
        positionals.append(a); i += 1

    if not model_id:
        die("Error: --model-id is required.\n"
            "Try: aws bedrock-runtime invoke-model --model-id <id> --body file://body.json out.json")
    if not body_arg:
        die("Error: --body is required (inline JSON or file://path).")
    if not positionals:
        die("Error: you must give an output file path as the last argument.\n"
            "Example: ... --body file://body.json out.json")
    outfile = positionals[-1]

    # resolve the body: file://path or inline JSON
    raw = body_arg
    if body_arg.startswith("file://"):
        path = body_arg[len("file://"):]
        try:
            raw = open(path).read()
        except Exception:
            die("Error: could not read body file '%s'." % path)
    try:
        req = json.loads(raw)
    except Exception:
        die("Error: --body is not valid JSON. It must look like:\n"
            '  {"prompt": "...", "max_tokens": 200, "temperature": 0.7}')

    prompt = req.get("prompt") or req.get("inputText") or ""
    max_tokens = req.get("max_tokens", req.get("maxTokenCount", 200))
    temperature = req.get("temperature", 0.7)
    try:
        max_tokens = int(max_tokens)
    except Exception:
        max_tokens = 200

    completion = gen_completion(prompt, model_id)
    words = completion.split()
    stop_reason = "end_turn"
    # honor a tiny max_tokens by truncating (1 word ~= 1 token here, for teaching)
    if max_tokens < len(words):
        completion = " ".join(words[:max(1, max_tokens)]) + " ..."
        stop_reason = "max_tokens"

    resp = {
        "completion": completion,
        "stop_reason": stop_reason,
        "model": model_id,
        "params_echo": {"max_tokens": max_tokens, "temperature": temperature},
        "usage": {"input_tokens": max(1, len(prompt.split())),
                  "output_tokens": len(completion.split())},
    }
    with open(outfile, "w") as f:
        json.dump(resp, f, indent=2)
    # the real CLI prints metadata to stdout and writes the model body to the outfile
    print(json.dumps({"contentType": "application/json",
                      "ResponseMetadata": {"HTTPStatusCode": 200}}, indent=2))
    sys.stderr.write("\n# (mock) wrote model response to %s  -- run: cat %s\n"
                     % (outfile, outfile))

def main():
    a = sys.argv[1:]
    if not a or a[0] in ("help", "--help", "-h"):
        print("usage: aws bedrock list-foundation-models")
        print("       aws bedrock-runtime invoke-model --model-id <id> "
              "--body file://body.json <outfile>")
        return
    if a[0] == "bedrock" and len(a) >= 2 and a[1] == "list-foundation-models":
        list_models(); return
    if a[0] == "bedrock-runtime" and len(a) >= 2 and a[1] == "invoke-model":
        invoke(a[2:]); return
    die("(mock aws) Unsupported command: %s\n"
        "This lab mocks only:\n"
        "  aws bedrock list-foundation-models\n"
        "  aws bedrock-runtime invoke-model ..." % " ".join(a))

if __name__ == "__main__":
    main()
AWSEOF
chmod +x /usr/local/bin/aws

# A friendly hint file the learner can peek at if needed.
cat > /root/bedrock/README.txt <<'EOF'
This lab uses a MOCK `aws` CLI. No AWS account, no network, no cost.
  aws bedrock list-foundation-models
  aws bedrock-runtime invoke-model --model-id <id> --body file://body.json out.json
EOF

cd /root/bedrock
