# Screen — Diary & Achievements

Diary tab and the achievements ("Traguardo") view. Sources:
`wiki/flow-screen/diario1.png` (Diario) and `diario2.png` (Traguardo). Bottom-bar shell tab
([[navigation]], tab 3).

## Purpose

Track the user's day-by-day diary entries and milestones/achievements, with filters, info
sheets, and product details.

## Screens

| Screen | Source | Contents |
|--------|--------|----------|
| **Diary** (Diario) | `diario1` | Entry list with status, filters modal, info sheets ("Tendina info"), product detail |
| **Achievement** (Traguardo) | `diario2` | Milestone view, filters modal, info screens, multiple product-detail sheets |

Shared patterns: "Modale filtri", "Tendina info", "Dettaglio prodotto" — see [[navigation]].

## Data / API

- Diary entries and achievements are **not documented** — see [[missing-apis]] (§4). Likely
  CMS-driven via [[cms-proxy]].

## Implementation notes

- Feature placement: `features/diary/presentation/`.

## Routing

`/diary` (shell branch 3) → `/diary/achievements`.

## Related

- [[navigation]]
- [[screen-statistics]]
- [[missing-apis]]
- [[README]]
