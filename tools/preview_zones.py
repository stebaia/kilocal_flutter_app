"""Render each silhouette with the ASSIGNED zone label next to each dot (from
assets/biotype_texts.json), as base64 PNGs embedded in a validation HTML."""

import base64
import io
import json
import os

from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
ASSETS = os.path.join(HERE, "..", "assets")
PERSON = os.path.join(ASSETS, "person")
OUT = os.path.join(HERE, "preview_out")

POINTS = {
    "m": {
        1: [(0.500, 0.064), (0.667, 0.429), (0.277, 0.616), (0.750, 0.770)],
        2: [(0.500, 0.064), (0.416, 0.351), (0.702, 0.402), (0.263, 0.494), (0.702, 0.503)],
        3: [(0.507, 0.064), (0.138, 0.305), (0.778, 0.514), (0.222, 0.556)],
        4: [(0.507, 0.078), (0.611, 0.439), (0.277, 0.517), (0.695, 0.779)],
        6: [(0.507, 0.059), (0.340, 0.399), (0.674, 0.429)],
        7: [(0.479, 0.048), (0.667, 0.204), (0.312, 0.413), (0.700, 0.429)],
    },
    "f": {
        1: [(0.500, 0.073), (0.328, 0.429), (0.808, 0.505), (0.371, 0.606), (0.722, 0.802)],
        2: [(0.493, 0.064), (0.450, 0.330), (0.664, 0.393), (0.306, 0.466), (0.736, 0.475)],
        3: [(0.500, 0.064), (0.192, 0.268), (0.328, 0.436), (0.715, 0.443), (0.278, 0.595)],
        4: [(0.500, 0.078), (0.371, 0.457), (0.786, 0.512), (0.371, 0.590), (0.700, 0.733)],
        5: [(0.478, 0.089), (0.435, 0.356), (0.700, 0.429), (0.228, 0.519)],
        6: [(0.478, 0.080), (0.364, 0.372), (0.651, 0.429)],
        7: [(0.493, 0.057), (0.321, 0.195), (0.300, 0.404), (0.700, 0.429)],
    },
}


def font(size):
    for p in ["/System/Library/Fonts/Supplemental/Arial Bold.ttf",
              "/System/Library/Fonts/Helvetica.ttc"]:
        if os.path.exists(p):
            return ImageFont.truetype(p, size)
    return ImageFont.load_default()


def render(g, n, points):
    gender = "man" if g == "m" else "woman"
    img = Image.open(os.path.join(PERSON, f"{gender}-type{n}.png")).convert("RGBA")
    w, h = img.size
    d = ImageDraw.Draw(img)
    fnt = font(20)
    r = 12
    for i, p in enumerate(points):
        fx, fy = POINTS[g][n][i]
        cx, cy = fx * w, fy * h
        d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(0, 0, 0, 230),
                  outline=(255, 255, 255), width=2)
        d.text((cx, cy), str(i), fill=(255, 255, 255), font=fnt, anchor="mm")
        # label to the side (right if dot on left half, else left)
        label = f"{i}: {p['zone']}"
        anchor = "lm" if fx < 0.5 else "rm"
        tx = cx + r + 6 if fx < 0.5 else cx - r - 6
        d.text((tx, cy), label, fill=(0, 0, 0), font=fnt, anchor=anchor)
    buf = io.BytesIO()
    img.save(buf, format="PNG")
    return base64.b64encode(buf.getvalue()).decode()


def main():
    texts = json.load(open(os.path.join(ASSETS, "biotype_texts.json")))
    cards = []
    for g in ("m", "f"):
        for n in sorted(POINTS[g]):
            key = str(n)
            if key not in texts or g not in texts[key]:
                continue
            pts = texts[key][g]["points"]
            b64 = render(g, n, pts)
            gender = "Uomo" if g == "m" else "Donna"
            cards.append((n, gender, b64))
    print(json.dumps([{"type": c[0], "gender": c[1], "img": c[2]} for c in cards]))


if __name__ == "__main__":
    main()
