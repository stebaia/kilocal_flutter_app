#!/usr/bin/env node
// -----------------------------------------------------------------------------
// extract_figma_texts.mjs
//
// Estrae TUTTI i text layer di un file (o di un nodo) Figma via API REST e li
// esporta in un JSON strutturato. Nessuna dipendenza esterna: usa fetch nativo
// (Node >= 18).
//
// I testi delle bottom sheet dei biotipi sono veri text layer, quindi l'export
// è automatico e fedele al 100% (niente OCR, niente trascrizione a mano).
//
// USO:
//   1. Genera un Figma personal access token:
//      Figma → Settings → Security → Personal access tokens → Generate new token
//      (scope minimo: "File content" in sola lettura).
//
//   2. Lancia:
//      FIGMA_TOKEN=xxxx node tools/extract_figma_texts.mjs "<link-figma>" [nodeId]
//
//      - <link-figma>: incolla direttamente l'URL del file o del frame Figma.
//        Lo script ne ricava file key e (se presente) node-id.
//      - [nodeId] (opzionale): limita l'estrazione a un solo nodo/sezione
//        (es. il frame che contiene le bottom sheet). Se lo ometti ma l'URL
//        contiene ?node-id=..., viene usato quello. Altrimenti estrae tutto.
//
//   Esempi:
//      FIGMA_TOKEN=xxxx node tools/extract_figma_texts.mjs \
//        "https://www.figma.com/design/ABC123/Kilocal?node-id=45-678"
//
//      FIGMA_TOKEN=xxxx node tools/extract_figma_texts.mjs \
//        "https://www.figma.com/design/ABC123/Kilocal" 45:678
//
//   Output: stampa il JSON su stdout e lo salva in tools/figma_texts.json
// -----------------------------------------------------------------------------

import { writeFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const TOKEN = process.env.FIGMA_TOKEN;
const rawUrlOrKey = process.argv[2];
const explicitNodeId = process.argv[3];

if (!TOKEN) {
  console.error("❌ Manca FIGMA_TOKEN. Esempio:\n   FIGMA_TOKEN=xxxx node tools/extract_figma_texts.mjs \"<link>\"");
  process.exit(1);
}
if (!rawUrlOrKey) {
  console.error("❌ Manca il link (o file key) di Figma come primo argomento.");
  process.exit(1);
}

// --- Parsing del link Figma -------------------------------------------------
// Accetta URL completi (figma.com/design/KEY/... , /file/KEY/...) o direttamente
// la file key. Estrae anche node-id da query string se presente.
function parseFigmaTarget(input) {
  // Se non sembra un URL, trattalo come file key nuda.
  if (!/^https?:\/\//i.test(input)) {
    return { fileKey: input, nodeId: null };
  }
  const url = new URL(input);
  const m = url.pathname.match(/\/(?:file|design|proto)\/([A-Za-z0-9]+)/);
  const fileKey = m ? m[1] : null;

  // Figma usa "45-678" negli URL ma "45:678" nell'API. Normalizziamo.
  let nodeId = url.searchParams.get("node-id");
  if (nodeId) nodeId = nodeId.replace(/-/g, ":");
  return { fileKey, nodeId };
}

const { fileKey, nodeId: urlNodeId } = parseFigmaTarget(rawUrlOrKey);
const nodeId = (explicitNodeId ? explicitNodeId.replace(/-/g, ":") : null) || urlNodeId;

if (!fileKey) {
  console.error("❌ Non riesco a ricavare la file key dal link. Controlla l'URL.");
  process.exit(1);
}

// --- Chiamata API -----------------------------------------------------------
async function figmaGet(path) {
  const res = await fetch(`https://api.figma.com/v1${path}`, {
    headers: { "X-Figma-Token": TOKEN },
  });
  if (!res.ok) {
    const body = await res.text();
    throw new Error(`Figma API ${res.status}: ${body}`);
  }
  return res.json();
}

// Restituisce il/i nodo/i radice da cui partire.
async function fetchRoots() {
  if (nodeId) {
    console.error(`ℹ️  Estraggo il solo nodo ${nodeId} dal file ${fileKey}…`);
    const data = await figmaGet(`/files/${fileKey}/nodes?ids=${encodeURIComponent(nodeId)}`);
    return Object.values(data.nodes).map((n) => n.document);
  }
  console.error(`ℹ️  Estraggo l'intero file ${fileKey}…`);
  const data = await figmaGet(`/files/${fileKey}`);
  return [data.document];
}

// --- Estrazione dei text layer ----------------------------------------------
// Percorre l'albero e raccoglie ogni nodo TYPE=TEXT con il "path" dei frame
// contenitori, così si può ricostruire genere/biotipo/punto dalla gerarchia.
function collectTexts(node, ancestry, out) {
  const name = node.name ?? "";
  const nextAncestry =
    node.type === "TEXT" ? ancestry : [...ancestry, name];

  if (node.type === "TEXT" && typeof node.characters === "string") {
    // Bounding box assoluto: serve a raggruppare geometricamente le card in
    // colonne/righe (biotipo/genere) quando la gerarchia dei nomi non lo dice.
    const bb = node.absoluteBoundingBox ?? null;
    out.push({
      id: node.id,
      layerName: name,
      // catena dei frame che lo contengono (utile per capire il biotipo)
      path: ancestry,
      text: node.characters,
      x: bb ? bb.x : null,
      y: bb ? bb.y : null,
      w: bb ? bb.width : null,
      h: bb ? bb.height : null,
    });
  }
  if (Array.isArray(node.children)) {
    for (const child of node.children) collectTexts(child, nextAncestry, out);
  }
}

// --- Main -------------------------------------------------------------------
try {
  const roots = await fetchRoots();
  const texts = [];
  for (const root of roots) {
    collectTexts(root, [], texts);
  }

  const result = {
    fileKey,
    nodeId: nodeId ?? null,
    extractedAt: new Date().toISOString(),
    count: texts.length,
    texts,
  };

  const outPath = join(dirname(fileURLToPath(import.meta.url)), "figma_texts.json");
  writeFileSync(outPath, JSON.stringify(result, null, 2), "utf8");

  console.error(`✅ Estratti ${texts.length} text layer.`);
  console.error(`📄 Salvato in: ${outPath}`);
  // JSON completo anche su stdout (per pipe/redirect)
  console.log(JSON.stringify(result, null, 2));
} catch (err) {
  console.error(`❌ ${err.message}`);
  process.exit(1);
}
