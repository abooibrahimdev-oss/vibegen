#!/usr/bin/env python3
"""Generate diagram.png for the 'Your First Bedrock Call' lab.
Mirrors starving-gpu/pipeline.png: white bg, rounded boxes, arrows, title, footer.
ASCII-safe text only (use -> not the arrow glyph). Uses Pillow (no matplotlib)."""
from PIL import Image, ImageDraw, ImageFont

W, H = 1000, 660
BG = (255, 255, 255)
INK = (40, 44, 52)
MUTE = (130, 136, 148)
LINE = (150, 156, 168)

# palette (border, fill) per box, echoing the template's soft cards
GREY = ((150, 156, 168), (238, 240, 243))
ORANGE = ((224, 142, 30), (253, 240, 215))
BLUE = ((43, 108, 196), (221, 233, 250))
GREEN = ((22, 130, 90), (216, 240, 230))

img = Image.new("RGB", (W, H), BG)
d = ImageDraw.Draw(img)

FNT = "/System/Library/Fonts/Helvetica.ttc"
def font(sz, idx=0):
    try:
        return ImageFont.truetype(FNT, sz, index=idx)
    except Exception:
        return ImageFont.load_default()

f_title = font(30, 1)   # bold-ish face
f_box   = font(21, 1)
f_sub   = font(14)
f_code  = font(15)
f_foot  = font(15)

def center(draw, cx, y, text, fnt, fill):
    w = draw.textlength(text, font=fnt)
    draw.text((cx - w / 2, y), text, font=fnt, fill=fill)

def rbox(x, y, w, h, colors, title, sub=None, r=14):
    border, fill = colors
    d.rounded_rectangle([x, y, x + w, y + h], radius=r, fill=fill, outline=border, width=3)
    cx = x + w / 2
    if sub:
        center(d, cx, y + h / 2 - 20, title, f_box, INK)
        center(d, cx, y + h / 2 + 8, sub, f_sub, MUTE)
    else:
        center(d, cx, y + h / 2 - 12, title, f_box, INK)

def arrow(x1, y, x2):
    d.line([(x1, y), (x2 - 9, y)], fill=LINE, width=4)
    d.polygon([(x2, y), (x2 - 12, y - 7), (x2 - 12, y + 7)], fill=LINE)

# --- title ---
center(d, W / 2, 30, "Your First Bedrock Call: one API, many models", f_title, INK)

# --- top flow row: four boxes + arrows ---
bw, bh, by = 200, 92, 110
gap = (W - 60 - 4 * bw) / 3
xs = [30 + i * (bw + gap) for i in range(4)]

rbox(xs[0], by, bw, bh, GREY,   "Your App",        "the request")
rbox(xs[1], by, bw, bh, ORANGE, "Bedrock Runtime", "invoke-model API")
rbox(xs[2], by, bw, bh, BLUE,   "Foundation Model", "Claude / Titan / Llama")
rbox(xs[3], by, bw, bh, GREEN,  "Response",         "completion JSON")

ay = by + bh / 2
for i in range(3):
    arrow(xs[i] + bw, ay, xs[i + 1])

# --- request shape panel ---
panel_y = 260
d.rounded_rectangle([30, panel_y, W - 30, panel_y + 150], radius=14,
                    fill=(248, 249, 251), outline=(220, 223, 230), width=2)
d.text((52, panel_y + 16), "The request you send ->", font=f_box, fill=INK)
req = [
    "model-id : anthropic.claude-3-sonnet",
    "body : {",
    '   "prompt"      : "Explain Bedrock in one line",',
    '   "max_tokens"  : 200,      # length cap',
    '   "temperature" : 0.7       # 0 = focused, 1 = creative',
    "}",
]
cy = panel_y + 50
for ln in req:
    d.text((70, cy), ln, font=f_code, fill=INK if not ln.startswith("   ") else (70, 80, 95))
    cy += 17

# --- response shape panel ---
resp_y = panel_y + 168
d.rounded_rectangle([30, resp_y, W - 30, resp_y + 86], radius=14,
                    fill=(216, 240, 230), outline=(22, 130, 90), width=2)
d.text((52, resp_y + 14), "The response you get back ->", font=f_box, fill=INK)
d.text((70, resp_y + 46), '{ "completion": "Bedrock is one API to call hosted '
       'foundation models...", "stop_reason": "stop" }', font=f_code, fill=(20, 70, 55))

# --- footer ---
fy = resp_y + 104
d.line([(40, fy), (W - 40, fy)], fill=(228, 230, 235), width=1)
center(d, W / 2, fy + 14, "Same invoke API for every model -- swap model-id, keep your code.",
       f_foot, INK)
center(d, W / 2, fy + 38, "Managed + serverless: no GPUs to run. Real calls bill your AWS "
       "account (this lab is mocked, $0).", f_foot, MUTE)

img.save("/Users/aboo.ibrahim.dev/Documents/GitHub/killercoda-labs/first-bedrock-call/assets/diagram.png")
print("wrote diagram.png", img.size)
