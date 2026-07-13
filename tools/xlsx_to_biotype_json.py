"""Convert 'TESTI SILHOUETTE APP _ KILOCAL.xlsx' into a structured JSON keyed by
biotype number + gender, with the body-map point texts and the path-area texts.

Sheet layout (one per type+gender):
  row "IL TUO PUNTO DI PARTENZA"  -> following rows are body-map points
      col B = zone label (TESTA / COSCE / ...), col C = "Title\nbody"
  row "IL PERCORSO PER STARE MEGLIO" -> following rows are the 4 path areas
      col B = area (ALLENAMENTO/...), col C = body

Output: tools/biotype_texts.json (later copied to assets/).
"""

import json
import re
import subprocess
import sys
import os

HERE = os.path.dirname(os.path.abspath(__file__))
XLSX = os.path.join(HERE, "TESTI SILHOUETTE APP _ KILOCAL.xlsx")

AREAS = {"ALLENAMENTO", "ALIMENTAZIONE", "BENESSERE", "INTEGRAZIONE"}
AREA_KEY = {
    "ALLENAMENTO": "allenamento",
    "ALIMENTAZIONE": "alimentazione",
    "BENESSERE": "benessere",
    "INTEGRAZIONE": "integrazione",
}


def load_sheets():
    raw = subprocess.check_output(
        [sys.executable, os.path.join(HERE, "read_xlsx.py"), XLSX]
    )
    return json.loads(raw)


def parse_sheet(name, rows):
    # name like "TIPO 1 - DONNA" / "TIPO 2 - UNISEX" / "TIPO 5 - SOLO DONNA"
    m = re.search(r"TIPO\s+(\d+)\s*-\s*(.+)", name)
    number = int(m.group(1))
    who = m.group(2).strip().upper()
    genders = []
    if "UNISEX" in who:
        genders = ["m", "f"]
    elif "SOLO DONNA" in who or who == "DONNA":
        genders = ["f"]
    elif who == "UOMO":
        genders = ["m"]
    else:
        genders = ["m", "f"]

    mode = None
    points = []
    areas = {}
    for r in rows:
        label = (r[1] if len(r) > 1 else "").strip()
        text = (r[2] if len(r) > 2 else "").strip()
        if not label:
            continue
        U = label.upper()
        if "PUNTO DI PARTENZA" in U:
            mode = "pt"
            continue
        if "PERCORSO PER STARE" in U:
            mode = "area"
            continue
        if mode == "pt":
            if U == "TESTO" or not text:
                continue
            # text = "Title\nbody..."; split first line as title.
            parts = text.split("\n", 1)
            title = parts[0].strip()
            body = parts[1].strip() if len(parts) > 1 else ""
            points.append({"zone": label, "title": title, "body": body})
        elif mode == "area":
            if U in AREAS:
                areas[AREA_KEY[U]] = text
    return number, genders, points, areas


def main():
    doc = load_sheets()
    # result[number][gender] = {points:[...], areas:{...}}
    result = {}
    for name in doc["sheets"]:
        rows = doc["data"][name]
        number, genders, points, areas = parse_sheet(name, rows)
        for g in genders:
            result.setdefault(str(number), {})[g] = {
                "points": points,
                "areas": areas,
            }

    out = os.path.join(HERE, "biotype_texts.json")
    with open(out, "w") as f:
        json.dump(result, f, ensure_ascii=False, indent=2)
    print("wrote", out)
    # quick summary
    for num in sorted(result, key=int):
        for g in result[num]:
            p = result[num][g]["points"]
            a = result[num][g]["areas"]
            print(f"  tipo {num} {g}: {len(p)} punti, aree={list(a)}")


if __name__ == "__main__":
    main()
