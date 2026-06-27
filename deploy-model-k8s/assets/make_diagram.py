#!/usr/bin/env python3
"""Generate diagram.png for the 'Deploy Your First AI Model on Kubernetes' lab.
Pure Pillow (no matplotlib). Mirrors the clean style of starving-gpu/pipeline.png:
white background, rounded boxes, gray arrows, a title, a footer rule + caption.
All text is ASCII-safe (uses '->' not the arrow glyph)."""
from PIL import Image, ImageDraw, ImageFont

W, H = 1000, 640
BG = (255, 255, 255)
INK = (26, 26, 46)          # near-black title/labels
SUB = (120, 126, 140)       # gray sub-labels / captions
ARROW = (138, 144, 156)     # gray arrows
RULE = (228, 230, 234)      # footer hairline

# palette (matched to the sibling lab)
GRAY_FILL, GRAY_LINE = (233, 234, 237), (184, 188, 196)
ORANGE_FILL, ORANGE_LINE = (253, 231, 194), (232, 147, 12)
GREEN_FILL, GREEN_LINE = (212, 237, 224), (26, 128, 84)

FONT = "/System/Library/Fonts/Helvetica.ttc"
def f(sz, idx=0):
    try:
        return ImageFont.truetype(FONT, sz, index=idx)
    except Exception:
        return ImageFont.load_default()

f_title = f(30, 1)   # bold
f_box   = f(21, 1)   # bold
f_sub   = f(14, 0)
f_cap   = f(15, 0)
f_badge = f(16, 1)

img = Image.new("RGB", (W, H), BG)
d = ImageDraw.Draw(img)

def center(draw, cx, y, text, font, fill):
    bb = draw.textbbox((0, 0), text, font=font)
    draw.text((cx - (bb[2] - bb[0]) / 2, y), text, font=font, fill=fill)

def box(x, y, w, h, fill, line, title, sub=None, r=14, lw=2):
    d.rounded_rectangle([x, y, x + w, y + h], radius=r, fill=fill, outline=line, width=lw)
    cx = x + w / 2
    if sub:
        center(d, cx, y + h / 2 - 20, title, f_box, INK)
        center(d, cx, y + h / 2 + 8, sub, f_sub, SUB)
    else:
        center(d, cx, y + h / 2 - 11, title, f_box, INK)

def arrow(x1, y, x2):
    d.line([x1, y, x2 - 9, y], fill=ARROW, width=4)
    d.polygon([(x2, y), (x2 - 12, y - 7), (x2 - 12, y + 7)], fill=ARROW)

# ---- Title ----
center(d, W / 2, 34, "Serving a Model on Kubernetes: one Service, many Pod replicas", f_title, INK)

# ---- Top flow: Client -> Service -> (Pods) ----
row_y = 120
bw, bh = 200, 96
client_x = 40
svc_x = 320

box(client_x, row_y, bw, bh, GRAY_FILL, GRAY_LINE, "Client", "curl / app")
arrow(client_x + bw, row_y + bh / 2, svc_x)
box(svc_x, row_y, bw, bh, ORANGE_FILL, ORANGE_LINE, "Service", "stable ClusterIP")

# Service fans out to 3 pods
pods_x = 720
pod_w, pod_h = 230, 56
pod_ys = [row_y - 34, row_y + 20, row_y + 74]
fan_from = (svc_x + bw, row_y + bh / 2)
for py in pod_ys:
    # connector line from service to each pod (load balancing)
    d.line([fan_from[0], fan_from[1], pods_x - 9, py + pod_h / 2], fill=ARROW, width=3)
    d.polygon([(pods_x, py + pod_h / 2),
               (pods_x - 12, py + pod_h / 2 - 6),
               (pods_x - 12, py + pod_h / 2 + 6)], fill=ARROW)
for py in pod_ys:
    box(pods_x, py, pod_w, pod_h, GREEN_FILL, GREEN_LINE, "Pod (model server)", r=12)

center(d, pods_x + pod_w / 2, pod_ys[-1] + pod_h + 12,
       "Deployment manages 3 replicas", f_sub, SUB)
center(d, svc_x + bw / 2, row_y + bh + 16,
       "load-balances across all healthy Pods", f_sub, SUB)

# ---- Scaling band: replicas=1 vs replicas=3 ----
band_y = 360
center(d, W / 2, band_y - 36, "Scale to handle more inference requests", f_badge, INK)

def replica_row(y, label, n, color, line, note):
    d.text((48, y + 12), label, font=f_cap, fill=INK)
    bx = 320
    box_w, gap = 66, 14
    for i in range(3):
        x = bx + i * (box_w + gap)
        if i < n:
            d.rounded_rectangle([x, y, x + box_w, y + 44], radius=10, fill=color, outline=line, width=2)
            center(d, x + box_w / 2, y + 12, "Pod", f_sub, INK)
        else:
            d.rounded_rectangle([x, y, x + box_w, y + 44], radius=10, fill=BG, outline=RULE, width=2)
    d.text((bx + 3 * (box_w + gap) + 18, y + 12), note, font=f_cap, fill=SUB)

replica_row(band_y, "replicas = 1", 1, GRAY_FILL, GRAY_LINE, "1 Pod -> limited throughput")
replica_row(band_y + 80, "replicas = 3", 3, GREEN_FILL, GREEN_LINE, "3 Pods -> 3x capacity, HA")

# ---- Footer rule + caption ----
fy = 560
d.line([40, fy, W - 40, fy], fill=RULE, width=2)
center(d, W / 2, fy + 18,
       "kubectl scale deploy ... --replicas=3   (an HPA can do this automatically under load)",
       f_cap, INK)
center(d, W / 2, fy + 42,
       "Model serving = a stateless, scalable Service. Same pattern scales up to Triton / NVIDIA NIM.",
       f_cap, SUB)

import os
out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "diagram.png")
img.save(out)
print("wrote", out)
