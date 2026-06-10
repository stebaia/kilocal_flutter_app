# App Navigation (Bottom Bar Shell)

The main app is a tabbed shell with a **bottom navigation bar (5 tabs)** present across most
program screens. Observed in nearly every Figma flow screen (`wiki/flow-screen/`).

## Bottom bar tabs

| # | Tab | Screen | Icon (approx.) |
|---|-----|--------|----------------|
| 1 | Home | [[screen-home]] | house |
| 2 | Path | [[screen-path]] | flow / arrows |
| 3 | Diary | [[screen-diary]] | tablet/board |
| 4 | (center) | benefits/momenti hub | bag |
| 5 | Integration | supplements/drop | drop |

> Exact tab → destination mapping is **inferred** from the screenshots and must be confirmed.
> The active tab is highlighted in brand red.

## Out-of-shell screens

These are pushed on top of the shell (no bottom bar persistence is implied by the design):
[[screen-statistics]], [[screen-notifications]], [[screen-momenti]], and most detail/info
sheets ("tendina info", "dettaglio prodotto", "modale filtri").

## Implementation notes

- Use GoRouter `StatefulShellRoute` (one branch per tab, preserved state) — this is **not yet
  reflected** in [[flutter-architecture]]'s router section (see [[missing-informations]] §2).
- Filters appear as bottom-sheet modals ("Modale filtri"); info appears as bottom-sheet
  drawers ("Tendina info"). Centralize both as shared widgets in `core/widgets/`.

## Routing

Shell at `/` with branches: `/home`, `/path`, `/diary`, `/benefits`, `/integration`.
Pre-shell flow: [[screen-splash]] → [[screen-onboarding]] → [[screen-login]] →
[[screen-survey]] → shell.

## Related

- [[screen-home]]
- [[screen-path]]
- [[screen-diary]]
- [[flutter-architecture]]
- [[missing-informations]]
- [[README]]
