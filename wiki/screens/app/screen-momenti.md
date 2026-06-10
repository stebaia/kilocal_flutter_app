# Screen — Momenti

Editorial content / challenge screen. Source: `wiki/flow-screen/momenti.png` (frame "Momenti").
Pushed on top of the shell — see [[navigation]].

## Purpose

Show a single editorial/challenge piece: hero image (e.g. trophy), title, body copy, and a
**"Meccanica"** section describing a multi-day challenge (e.g. "Ogni giorno per 7 giorni…").

## Layout

| Element | Description |
|---------|-------------|
| Header | Back + "Momenti" + info icon |
| Hero | Brand-red banner with illustration (trophy) |
| Title + body | Content text |
| Meccanica | Day-by-day challenge rules (Giorno 1, Giorno 2, …) |

## Data / API

- Momenti content is **not documented** — see [[missing-apis]] (§7). Likely CMS-driven via
  [[cms-proxy]].

## Implementation notes

- Feature placement: `features/momenti/presentation/`.

## Routing

`/momenti/{id}`.

## Related

- [[navigation]]
- [[screen-home]]
- [[missing-apis]]
- [[README]]
