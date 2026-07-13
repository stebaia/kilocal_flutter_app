"""Detect biotype silhouette dots in assets/person/type-N-man.png reference
images and print their fractional (x, y) positions.

The dots are the dark-green filled circles. We threshold on that dark-green,
cluster connected pixels, and report each cluster centroid as a fraction of the
image width/height (origin top-left). Output is ready to paste into the Dart
coordinate map."""

import glob
import os
import re
from collections import deque

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
ASSETS = os.path.join(HERE, "..", "assets", "person")


def is_dot(px):
    """The dot (ring + center) is the *saturated, darker* accent color; the
    silhouette fill is a pale pastel of the same hue. Both share a hue but the
    fill is light (high min channel) while the dot is vivid (low min channel,
    high chroma). This is hue-agnostic, so it works for green/pink/etc."""
    r, g, b = px[0], px[1], px[2]
    a = px[3] if len(px) > 3 else 255
    if a < 128:
        return False
    mx, mn = max(r, g, b), min(r, g, b)
    chroma = mx - mn
    # Pale silhouette fill: min channel stays high (washed out). Vivid dot:
    # strong chroma and a low min channel. Exclude near-white/near-transparent.
    # chroma >= 75 catches dark purple dots (#82368C, chroma 86) too.
    return chroma > 74 and mn < 150


def cluster(mask, w, h):
    seen = [[False] * w for _ in range(h)]
    clusters = []
    for y in range(h):
        for x in range(w):
            if mask[y][x] and not seen[y][x]:
                q = deque([(x, y)])
                seen[y][x] = True
                pts = []
                while q:
                    cx, cy = q.popleft()
                    pts.append((cx, cy))
                    for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                        nx, ny = cx + dx, cy + dy
                        if 0 <= nx < w and 0 <= ny < h and mask[ny][nx] and not seen[ny][nx]:
                            seen[ny][nx] = True
                            q.append((nx, ny))
                if len(pts) > 40:  # ignore noise / thin outlines
                    clusters.append(pts)
    return clusters


def process(path):
    img = Image.open(path).convert("RGBA")
    w, h = img.size
    px = img.load()
    mask = [[is_dot(px[x, y]) for x in range(w)] for y in range(h)]
    clusters = cluster(mask, w, h)
    # Centroid + weight (pixel count) per raw cluster.
    raw = []
    for pts in clusters:
        cx = sum(p[0] for p in pts) / len(pts)
        cy = sum(p[1] for p in pts) / len(pts)
        raw.append([cx, cy, len(pts)])

    # Merge clusters whose centroids are within `merge_dist` px — the dark ring
    # and the filled center of the same dot land as two clusters otherwise.
    merge_dist = 0.06 * max(w, h)
    merged = []
    for c in sorted(raw, key=lambda r: -r[2]):
        for m in merged:
            if abs(m[0] - c[0]) < merge_dist and abs(m[1] - c[1]) < merge_dist:
                tot = m[2] + c[2]
                m[0] = (m[0] * m[2] + c[0] * c[2]) / tot
                m[1] = (m[1] * m[2] + c[1] * c[2]) / tot
                m[2] = tot
                break
        else:
            merged.append(c)

    dots = [(cx / w, cy / h, wt) for cx, cy, wt in merged]
    dots.sort(key=lambda d: (d[1], d[0]))
    return w, h, dots


def main():
    import sys

    gender = sys.argv[1] if len(sys.argv) > 1 else "man"
    files = sorted(glob.glob(os.path.join(ASSETS, f"type-*-{gender}.png")))
    for f in files:
        m = re.search(rf"type-(\d+)-{gender}", os.path.basename(f))
        n = m.group(1) if m else "?"
        w, h, dots = process(f)
        coords = ", ".join(f"Offset({x:.3f}, {y:.3f})" for x, y, _ in dots)
        print(f"// type {n}  ({w}x{h}, {len(dots)} dots)")
        print(f"{n}: [{coords}],")
        print()


if __name__ == "__main__":
    main()
