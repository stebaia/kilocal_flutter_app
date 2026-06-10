# Screen — Path (Il tuo percorso)

The program journey hub and its sub-hubs. Sources: `wiki/flow-screen/percorso1.png` …
`percorso6.png`. Bottom-bar shell tab ([[navigation]], tab 2).

## Purpose

Present the user's program ("Il tuo percorso") with **overall progress** and four content
areas plus an extra-materials hub. Each area is a hub leading to content pages and detail
sheets.

## Path overview (`percorso1`)

| Element | Description |
|---------|-------------|
| Progress | "Progressi complessivi" bar + counter (e.g. `23/132`) |
| Area tiles | Allenamento, Alimentazione, Benessere, Integrazione (2×2 grid) |
| Info view | "Attivi ora" list with per-month/phase completion (e.g. "Allenamento Mese 1 — completato al XX%") |

## Sub-hubs

| Hub | Source | Contents |
|-----|--------|----------|
| **Training** (Allenamento) | `percorso2` | Hub list → workout page → **timer** sheet → content (video/exercise) |
| **Nutrition** (Alimentazione) | `percorso3` | Hub list → recipe/step page ("Step 1…") → activity checklist |
| **Wellbeing** (Benessere) | `percorso4` | Categories: Mindfulness, Self care, Stili di vita → category content |
| **Integration** (Integrazione) | `percorso5` | Hub list → supplement page → info sheet → product detail |
| **Extra materials** (Materiali Extra) | `percorso6` | Categorized list → material page → filters modal |

Shared patterns: "Tendina info" (info bottom sheet), "Dettaglio prodotto" (product detail),
"Modale filtri" (filters modal) — see [[navigation]].

## Data / API

- Path structure, progress, and per-hub content are **not documented** — see [[missing-apis]]
  (§3). Likely CMS-driven via [[cms-proxy]].

## Implementation notes

- Feature placement: `features/path/presentation/` with sub-folders per hub.
- The training **timer** needs a countdown/stopwatch widget.

## Routing

`/path` (shell branch 2) → `/path/{hub}` → `/path/{hub}/{contentId}`.

## Related

- [[navigation]]
- [[screen-statistics]]
- [[missing-apis]]
- [[cms-proxy]]
- [[README]]
