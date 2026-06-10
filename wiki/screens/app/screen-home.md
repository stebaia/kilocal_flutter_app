# Screen — Home

Main landing tab of the program app. Source: `wiki/flow-screen/hero-home.png`
(frames "HOME" and "Hero HOME"). Lives in the bottom-bar shell ([[navigation]], tab 1).

## Purpose

Give the user an at-a-glance view of their program: a management card, overall **progress
(%)**, and a scrollable **hero carousel** of editorial/promo content.

## Layout

| Element | Description |
|---------|-------------|
| Header | Greeting card ("Ciao Management…") with action icon |
| Progress | Circular **80%** progress indicator (overall program completion) |
| Quick cards | Tiles linking to sections (month/phase, areas) |
| Hero carousel | Vertical list of hero cards (image + title), brand-red styled |
| Bottom bar | 5-tab navigation ([[navigation]]) |

## Data / API

- Program status / progress and hero content are **not documented** — see [[missing-apis]]
  (§2). Likely CMS-driven via [[cms-proxy]].

## Implementation notes

- Feature placement: `features/home/presentation/`.
- Circular progress as a reusable widget (also used in [[screen-statistics]]).

## Routing

`/home` (shell branch 1).

## Related

- [[navigation]]
- [[screen-path]]
- [[screen-statistics]]
- [[missing-apis]]
- [[design-system]]
- [[README]]
