"""Assign each sheet zone text to a specific dot INDEX per type+gender, producing
the final assets/biotype_texts.json consumed by the app, plus a validation HTML.

MAPPING[gender][type] = [zone_for_dot0, zone_for_dot1, ...] — the zone label
placed at each dot index (order = kMan/WomanBiotypeBodyPoints). Reasoned from the
indexed overlays (tools/preview_out/*-idx.png) + zone semantics. TESTA is always
dot 0 (topmost). Ambiguous abdomen/flank zones are best-effort; validate visually.
"""

import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))
TEXTS = os.path.join(HERE, "biotype_texts.json")

# dot index -> zone label. Must be a permutation of that sheet's zones.
MAPPING = {
    "m": {
        # dots(y asc): 0 head, 1 trunk-R, 2 thigh-L, 3 lower-leg-R
        1: ["TESTA", "ADDOME SUL FIANCO", "COSCE", "POLPACCIO"],
        # 0 head,1 upper-centre,2 upper-R,3 lower-L,4 lower-R
        2: ["TESTA", "PANCIA ALTA", "FIANCHI ALTI", "PANCIA BASSA", "LATO DELLA PANCIA"],
        # 0 head,1 arm-L(high-left),2 flank/leg-R,3 lower-L
        3: ["TESTA", "BRACCIA", "GAMBE O FIANCO", "ADDOME"],
        # 0 head,1 abdomen-R,2 thigh-L,3 knee-R
        4: ["TESTA", "BASSO ADDOME", "COSCE", "GINOCCHIA"],
        # 0 head,1 abdomen-centre-low,2 abdomen-high-R
        6: ["TESTA", "ADDOME CENTRALE UN PO' BASSO", "ADDOME ALTO"],
        # 0 head,1 shoulder/chest-R,2 flank-L,3 abdomen-R
        7: ["TESTA", "SPALLE", "FIANCO ALTO", "ADDOME"],
    },
    "f": {
        # dots(y asc): 0 head,1 waist-L,2 flank-R,3 thigh-L,4 lower-leg-R
        1: ["TESTA", "ADDOME SUL FIANCO", "FIANCO", "COSCE", "POLPACCIO"],
        2: ["TESTA", "PANCIA ALTA", "FIANCHI ALTI", "PANCIA BASSA", "LATO DELLA PANCIA"],
        # 0 head,1 arm-L(high),2 abdomen-centre,3 flank-R,4 lower-L
        3: ["TESTA", "BRACCIA", "ADDOME", "GAMBE O FIANCO", "COSCE"],
        # 0 head,1 thigh-L,2 flank-R,3 low-abdomen-L,4 knee-R
        4: ["TESTA", "COSCE", "FIANCO", "BASSO ADDOME", "GINOCCHIA"],
        # 0 head,1 abdomen-centre-low,2 abdomen-high-R,3 flank-L
        5: ["TESTA", "ADDOME CENTRALE UN PO' BASSO", "ALTO ADDOME", "FIANCHI"],
        6: ["TESTA", "ADDOME CENTRALE UN PO' BASSO", "ADDOME ALTO"],
        # 0 head,1 shoulder-L(high),2 flank-L,3 abdomen-R
        7: ["TESTA", "SPALLE", "FIANCO ALTO", "ADDOME"],
    },
}


def main():
    texts = json.load(open(TEXTS))
    out = {}
    problems = []
    for g in ("m", "f"):
        for num, order in MAPPING[g].items():
            key = str(num)
            if key not in texts or g not in texts[key]:
                problems.append(f"no texts for {num} {g}")
                continue
            entry = texts[key][g]
            by_zone = {p["zone"]: p for p in entry["points"]}
            if set(order) != set(by_zone):
                problems.append(
                    f"type {num} {g}: mapping {order} != zones {list(by_zone)}"
                )
                continue
            ordered_points = [
                {"title": by_zone[z]["title"], "body": by_zone[z]["body"], "zone": z}
                for z in order
            ]
            out.setdefault(key, {})[g] = {
                "points": ordered_points,
                "areas": entry["areas"],
            }

    if problems:
        print("PROBLEMS:")
        for p in problems:
            print("  ", p)

    dst = os.path.join(HERE, "..", "assets", "biotype_texts.json")
    with open(dst, "w") as f:
        json.dump(out, f, ensure_ascii=False, indent=2)
    print("wrote", os.path.relpath(dst, os.path.join(HERE, "..")))


if __name__ == "__main__":
    main()
