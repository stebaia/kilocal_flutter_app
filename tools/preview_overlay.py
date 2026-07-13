"""Composite the clean silhouette (man-typeN.png) with the dots drawn at the
fractional positions from the Dart map, to verify alignment the same way the
widget lays them out (AspectRatio box == image box, so fractions map directly)."""

import os

from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
ASSETS = os.path.join(HERE, "..", "assets", "person")
OUT = os.path.join(HERE, "preview_out")
os.makedirs(OUT, exist_ok=True)

import sys

# Mirror of kManBiotypeBodyPoints / kWomanBiotypeBodyPoints + accent colors.
POINTS_BY_GENDER = {
    "man": {
        1: [(0.500, 0.064), (0.667, 0.429), (0.277, 0.616), (0.750, 0.770)],
        2: [(0.500, 0.064), (0.416, 0.351), (0.702, 0.402), (0.263, 0.494), (0.702, 0.503)],
        3: [(0.507, 0.064), (0.138, 0.305), (0.778, 0.514), (0.222, 0.556)],
        4: [(0.507, 0.078), (0.611, 0.439), (0.277, 0.517), (0.695, 0.779)],
        6: [(0.507, 0.059), (0.340, 0.399), (0.674, 0.429)],
        7: [(0.479, 0.048), (0.667, 0.204), (0.312, 0.413), (0.646, 0.450)],
    },
    "woman": {
        1: [(0.500, 0.073), (0.328, 0.429), (0.808, 0.505), (0.371, 0.606), (0.722, 0.802)],
        2: [(0.493, 0.064), (0.450, 0.330), (0.664, 0.393), (0.306, 0.466), (0.736, 0.475)],
        3: [(0.500, 0.064), (0.192, 0.268), (0.328, 0.436), (0.715, 0.443), (0.278, 0.595)],
        4: [(0.500, 0.078), (0.371, 0.457), (0.786, 0.512), (0.371, 0.590), (0.700, 0.733)],
        5: [(0.478, 0.089), (0.435, 0.356), (0.700, 0.429), (0.228, 0.519)],
        6: [(0.478, 0.080), (0.364, 0.372), (0.651, 0.429)],
        7: [(0.493, 0.057), (0.321, 0.195), (0.300, 0.404), (0.700, 0.429)],
    },
}
COLORS = {
    1: (0, 150, 64),
    2: (29, 113, 184),
    3: (239, 121, 0),
    4: (230, 0, 126),
    5: (130, 54, 140),
    6: (0, 172, 172),
    7: (0, 159, 227),
}


def main():
    gender = sys.argv[1] if len(sys.argv) > 1 else "man"
    for n, pts in POINTS_BY_GENDER[gender].items():
        path = os.path.join(ASSETS, f"{gender}-type{n}.png")
        img = Image.open(path).convert("RGBA")
        w, h = img.size
        d = ImageDraw.Draw(img)
        color = COLORS[n]
        r_out = int(0.045 * h) // 2 + 6
        r_in = r_out // 2
        for fx, fy in pts:
            cx, cy = fx * w, fy * h
            # white disc + colored ring + filled center (mirrors the widget dot).
            d.ellipse([cx - r_out, cy - r_out, cx + r_out, cy + r_out],
                      fill=(255, 255, 255, 255), outline=color, width=3)
            d.ellipse([cx - r_in, cy - r_in, cx + r_in, cy + r_in], fill=color)
        out = os.path.join(OUT, f"{gender}-type{n}-dots.png")
        img.save(out)
        print(f"wrote {out}")


if __name__ == "__main__":
    main()
