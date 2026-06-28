#!/bin/bash
# Set up the "Prompt Engineering" lab on a plain Ubuntu box.
# There is NO real LLM and NO network call here. We install a MOCK `ask` CLI that
# imitates ONE fixed language model: the SAME model every call, whose OUTPUT changes
# based on HOW you prompt it. That's the whole lesson — the prompt is the program.

mkdir -p /root/prompt
cd /root/prompt

# --- a fixed customer review the "model" will work on (you paste it into prompts) ---
cat > /root/prompt/review.txt <<'EOF'
"Honestly disappointed. The Nimbus R7 looks great, but it keeps disconnecting
from wifi after the latest update, and support hasn't replied to my ticket in 3 days."
EOF

# --- the MOCK `ask` CLI (python3) ---
cat > /usr/local/bin/ask <<'ASKEOF'
#!/usr/bin/env python3
"""MOCK LLM 'ask' CLI — learn prompt engineering for $0, no API key, no network.
It simulates ONE fixed model. You don't get a better model by asking again — you get
a better ANSWER by writing a better PROMPT.

Usage:
  ask -f prompt.txt              # print the model's response
  ask -f prompt.txt -o out.txt   # also save the response to out.txt
  ask -p "an inline prompt"      # prompt straight from the command line
"""
import sys, json

def parse(argv):
    pf=of=inline=None; i=0
    while i < len(argv):
        a=argv[i]
        if a in ("-f","--file") and i+1 < len(argv): pf=argv[i+1]; i+=2; continue
        if a in ("-o","--out")  and i+1 < len(argv): of=argv[i+1]; i+=2; continue
        if a in ("-p","--prompt") and i+1 < len(argv): inline=argv[i+1]; i+=2; continue
        if a in ("-h","--help"): print(__doc__); sys.exit(0)
        inline=a; i+=1
    return pf, of, inline

def main():
    pf, of, inline = parse(sys.argv[1:])
    if pf:
        try: prompt=open(pf).read()
        except Exception: sys.stderr.write("\nError: can't read prompt file '%s'.\n"%pf); sys.exit(2)
    elif inline is not None:
        prompt=inline
    else:
        prompt=sys.stdin.read()
    p=prompt.lower()

    # --- detect which prompt-engineering techniques you used ---
    wants_json = "json" in p
    fewshot = (p.count("->")>=2) or (p.count("|")>=2 and "sentiment" in p)
    specific = any(k in p for k in ["one sentence","one-sentence","1 sentence","single sentence",
                   "in 10 words","in 15 words","concise","only the","just the","summarize","summarise"])

    # The model "reads" the review in your prompt. Output quality tracks YOUR prompt.
    if wants_json:
        resp = json.dumps({"sentiment":"negative","category":"connectivity","urgency":"high"}, indent=2)
        tag  = "structured output (JSON) — reliable and machine-parseable"
    elif fewshot:
        resp = "negative | connectivity | high"
        tag  = "matched your examples — exact format, every time"
    elif specific:
        resp = ("The customer is frustrated that the Nimbus R7 keeps dropping Wi-Fi after the latest "
                "update, and support hasn't replied in 3 days.")
        tag  = "concise — it answered the specific question you asked"
    else:
        resp = ("Thank you for sharing this product review! Customer feedback is such a rich and "
                "fascinating topic. A review like this can touch on design, build quality, performance, "
                "reliability, the support experience, pricing, and overall satisfaction — and there are "
                "countless ways one might interpret it depending on your goals. One could explore the "
                "emotional tone, the specific issues, possible root causes, comparisons to similar "
                "products, and what an ideal response might look like. Ultimately, feedback is valuable "
                "and there is a great deal one could say about it...")
        tag  = "vague prompt -> rambling, generic, unusable"

    if of:
        try: open(of,"w").write(resp)
        except Exception: pass
    sys.stderr.write("\n# (mock LLM) %s\n"%tag)
    print(resp)

if __name__=="__main__":
    main()
ASKEOF
chmod +x /usr/local/bin/ask

cat > /root/prompt/README.txt <<'EOF'
This lab uses a MOCK `ask` CLI — one fixed model, no API key, no network, no cost.
Same model every call. Better PROMPT = better ANSWER.
  ask -f prompt.txt            # print the response
  ask -f prompt.txt -o out.txt # also save it
EOF

cd /root/prompt
