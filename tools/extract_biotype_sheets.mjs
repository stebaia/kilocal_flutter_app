#!/usr/bin/env node
// -----------------------------------------------------------------------------
// extract_biotype_sheets.mjs
//
// Estrae le bottom sheet "Tendine per Sezione tipo" (i testi per biotipo/genere
// della silhouette interattiva) dal Figma KILOCAL PROGRAM e le struttura in
// JSON: una entry per tendina, con le sue card {titolo, corpo, cta}.
//
// A differenza di extract_figma_texts.mjs (che appiattisce tutti i TEXT), qui
// preserviamo il FRAME PADRE reale di ogni tendina, così ogni bottom sheet resta
// un blocco coeso di card. Il biotipo/genere non è nel nome del frame (si
// chiamano tutti "Tendine per Sezione tipo"), quindi lo lasciamo dedurre a valle
// dall'ordine + dal contenuto (maschile/femminile) e dalla posizione y/x.
//
// USO:
//   FIGMA_TOKEN=xxxx node tools/extract_biotype_sheets.mjs
//
// Output: tools/biotype_sheets.json
// -----------------------------------------------------------------------------

import { writeFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const TOKEN = process.env.FIGMA_TOKEN;
const FILE_KEY = "wvV8JURTECntVCsHl5sNLc";
// node-id della sezione "MOBILE APP" (contiene le Tendine). Vale la pena tenerlo
// ampio: filtriamo per nome frame lato client.
const ROOT_NODE = "2720:47641";
const TARGET_FRAME_NAME = "Tendine per Sezione tipo";

if (!TOKEN) {
  console.error("❌ Manca FIGMA_TOKEN.");
  process.exit(1);
}

async function figmaGet(path) {
  const res = await fetch(`https://api.figma.com/v1${path}`, {
    headers: { "X-Figma-Token": TOKEN },
  });
  if (!res.ok) throw new Error(`Figma API ${res.status}: ${await res.text()}`);
  return res.json();
}

// Raccoglie ricorsivamente tutti i TEXT sotto un nodo, in ordine di lettura.
function collectTexts(node, out) {
  if (node.type === "TEXT" && typeof node.characters === "string") {
    const bb = node.absoluteBoundingBox ?? {};
    out.push({ text: node.characters, x: bb.x ?? null, y: bb.y ?? null });
  }
  if (Array.isArray(node.children)) for (const c of node.children) collectTexts(c, out);
}

// Trova ricorsivamente tutti i frame che si chiamano TARGET_FRAME_NAME.
function findTendine(node, out) {
  if (node.name === TARGET_FRAME_NAME && node.type !== "TEXT") out.push(node);
  else if (Array.isArray(node.children)) for (const c of node.children) findTendine(c, out);
  // Nota: non scendiamo DENTRO una tendina trovata (evita doppioni annidati).
}

// Una card = coppia [titolo breve] + [corpo lungo]. Nel Figma il titolo è un
// TEXT corto (es. "Come ti senti") seguito dal corpo. Ricostruiamo le card
// appaiando titolo→corpo in ordine di lettura, saltando i CTA noti.
const KNOWN_TITLES = new Set([
  "Come ti senti",
  "Addome e zona epatica",
  "Cosce e glutei",
  "Gambe e caviglie",
  "Fianchi",
  "Allenamento",
  "Alimentazione",
  "Benessere",
  "Integrazione",
]);
const CTA_TEXTS = new Set(["Vedi sezione dedicata", "Via al contenuto"]);

function buildCards(texts) {
  const cards = [];
  let cta = null;
  for (let i = 0; i < texts.length; i++) {
    const t = texts[i].text.trim();
    if (CTA_TEXTS.has(t)) { cta = t; continue; }
    if (KNOWN_TITLES.has(t)) {
      // il prossimo TEXT non-titolo/non-cta è il corpo
      let body = "";
      for (let j = i + 1; j < texts.length; j++) {
        const nt = texts[j].text.trim();
        if (KNOWN_TITLES.has(nt) || CTA_TEXTS.has(nt)) break;
        body = texts[j].text; // preserva newline originali
        i = j;
        break;
      }
      cards.push({ title: t, body });
    }
  }
  return { cards, cta };
}

// Euristica genere dal contenuto: cerca desinenze/aggettivi femminili tipici.
function guessGender(cards) {
  const blob = cards.map((c) => c.body).join(" ").toLowerCase();
  const fem = (blob.match(/\b(appesantita|gonfia|rallentata|leggera|stanca|pronta|sola)\b/g) || []).length;
  const masc = (blob.match(/\b(appesantito|gonfio|rallentato|leggero|stanco|pronto|solo)\b/g) || []).length;
  if (fem > masc) return "F";
  if (masc > fem) return "M";
  return "?";
}

try {
  console.error(`ℹ️  Scarico ${ROOT_NODE} da ${FILE_KEY}…`);
  const data = await figmaGet(`/files/${FILE_KEY}/nodes?ids=${encodeURIComponent(ROOT_NODE)}`);
  const roots = Object.values(data.nodes).map((n) => n.document);

  const tendine = [];
  for (const r of roots) findTendine(r, tendine);
  console.error(`ℹ️  Trovate ${tendine.length} tendine "${TARGET_FRAME_NAME}".`);

  const sheets = [];
  for (const frame of tendine) {
    const texts = [];
    collectTexts(frame, texts);
    // scarta le tendine placeholder (solo lorem ipsum)
    const hasReal = texts.some((t) => !/lorem ipsum/i.test(t.text) && !KNOWN_TITLES.has(t.text.trim()) && !CTA_TEXTS.has(t.text.trim()));
    if (!hasReal) continue;
    const { cards, cta } = buildCards(texts);
    if (!cards.length) continue;
    // posizione del frame (per ordinare/raggruppare a valle)
    const bb = frame.absoluteBoundingBox ?? {};
    sheets.push({
      frameId: frame.id,
      x: bb.x ?? null,
      y: bb.y ?? null,
      gender: guessGender(cards),
      hasCta: cta != null,
      cta,
      cards,
    });
  }

  // ordina per posizione: righe (y) poi colonne (x)
  sheets.sort((a, b) => (a.y - b.y) || (a.x - b.x));

  // Ogni tendina è UNA bottom sheet = una sola card (titolo + corpo + eventuale
  // CTA). Appiattiamo in una lista pulita e non etichettata: il biotipo (Tipo
  // 1–7) non è ricavabile dal Figma in modo affidabile, quindi lo lasciamo a
  // chi conosce il file. La posizione (x,y) è conservata come riferimento.
  const items = sheets.map((s, i) => ({
    index: i,
    frameId: s.frameId,
    x: s.x,
    y: s.y,
    gender: s.gender, // "M" | "F" | "?" (dedotto dal testo, non garantito)
    section: s.cards[0].title, // es. "Alimentazione", "Come ti senti"
    body: s.cards[0].body,
    cta: s.cta, // testo del bottone, o null
  }));

  const out = {
    fileKey: FILE_KEY,
    extractedAt: new Date().toISOString(),
    count: items.length,
    note: "Testi reali estratti dalle tendine 'Tendine per Sezione tipo'. Biotipo (Tipo 1-7) NON etichettato: da assegnare a mano su Figma. gender dedotto dal testo, verificare.",
    items,
  };
  const outPath = join(dirname(fileURLToPath(import.meta.url)), "biotype_sheets.json");
  writeFileSync(outPath, JSON.stringify(out, null, 2), "utf8");
  console.error(`✅ ${items.length} testi reali → ${outPath}`);
} catch (e) {
  console.error(`❌ ${e.message}`);
  process.exit(1);
}
