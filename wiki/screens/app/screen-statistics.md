# Screen — Statistics

Activity statistics for the current month. Source: `wiki/flow-screen/statistiche.png`
(frame "Statistiche"). Pushed on top of the shell (no persistent bottom-bar role) — see
[[navigation]].

## Purpose

Show completion per program area for the current month, with a circular percentage and an
`x/y attività` counter.

## Layout

Header "Statistiche mese corrente" + calendar icon, then one card per area:

| Area | Example | Indicator |
|------|---------|-----------|
| Allenamento (Training) | Mese 1 — 3/15 attività | circular **80%** |
| Alimentazione (Nutrition) | Mese 1 — 5/18 attività | circular **80%** |
| Benessere (Wellbeing) | Mese 1 — 8/25 attività | circular **80%** |
| Integrazione (Integration) | Fase 1 — 5/19 attività | circular **80%** |

## Data / API

- Per-area, per-month percentages and counts are **not documented** — see [[missing-apis]]
  (§5).

## Implementation notes

- Reuse the circular-progress widget from [[screen-home]].
- Month/phase selectable via the calendar icon.
- Feature placement: `features/statistics/presentation/`.

## Routing

`/statistics` (pushed route).

## Related

- [[screen-home]]
- [[screen-path]]
- [[missing-apis]]
- [[README]]
