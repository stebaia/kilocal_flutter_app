"""Minimal stdlib-only .xlsx reader: dumps sheet names and rows as JSON so the
silhouette texts can be inspected without openpyxl."""

import json
import re
import sys
import zipfile
from xml.etree import ElementTree as ET

NS = "{http://schemas.openxmlformats.org/spreadsheetml/2006/main}"
PATH = sys.argv[1]


def col_to_idx(ref):
    m = re.match(r"([A-Z]+)", ref)
    letters = m.group(1)
    n = 0
    for c in letters:
        n = n * 26 + (ord(c) - 64)
    return n - 1


with zipfile.ZipFile(PATH) as z:
    # shared strings
    shared = []
    if "xl/sharedStrings.xml" in z.namelist():
        root = ET.fromstring(z.read("xl/sharedStrings.xml"))
        for si in root.findall(f"{NS}si"):
            # concatenate all text runs
            txt = "".join(t.text or "" for t in si.iter(f"{NS}t"))
            shared.append(txt)

    # workbook: sheet name -> r:id -> target
    wb = ET.fromstring(z.read("xl/workbook.xml"))
    rels = ET.fromstring(z.read("xl/_rels/workbook.xml.rels"))
    RNS = "{http://schemas.openxmlformats.org/package/2006/relationships}"
    rid_target = {r.get("Id"): r.get("Target") for r in rels.findall(f"{RNS}Relationship")}
    ORNS = "{http://schemas.openxmlformats.org/officeDocument/2006/relationships}"

    sheets = []
    for s in wb.find(f"{NS}sheets").findall(f"{NS}sheet"):
        name = s.get("name")
        rid = s.get(f"{ORNS}id")
        target = rid_target[rid]
        if not target.startswith("xl/"):
            target = "xl/" + target
        sheets.append((name, target))

    which = sys.argv[2] if len(sys.argv) > 2 else None
    out = {}
    for name, target in sheets:
        if which and which.lower() not in name.lower():
            out[name] = "(skipped)"
            continue
        root = ET.fromstring(z.read(target))
        rows = []
        for row in root.iter(f"{NS}row"):
            cells = {}
            maxc = -1
            for c in row.findall(f"{NS}c"):
                ref = c.get("r")
                idx = col_to_idx(ref)
                maxc = max(maxc, idx)
                v = c.find(f"{NS}v")
                val = ""
                if v is not None:
                    if c.get("t") == "s":
                        val = shared[int(v.text)]
                    else:
                        val = v.text
                cells[idx] = val
            rows.append([cells.get(i, "") for i in range(maxc + 1)])
        out[name] = rows

    print(json.dumps({"sheets": [s[0] for s in sheets], "data": out}, ensure_ascii=False))
