# Screen — Benefits

Partner benefits and discount codes. Source: `wiki/flow-screen/benefit.png` (frame "BENEFIT").
Reached from the shell ([[navigation]]).

## Purpose

List **active benefits** and partner perks (e.g. Twitch, Spotify, "Refeego"), with a detail
view exposing a partner **discount code** and external redirects.

## Screens

| Screen | Contents |
|--------|----------|
| **Benefits** (Benefit attivi) | Featured partner + recommended partners list; "Visualizza dettagli" |
| **Filters modal** (Modale filtri) | Benefit attivi / passati / coming soon |
| **Benefit detail** (Dettaglio Benefit) | Partner description, discount code (e.g. `REDSKLO`), CTAs: "Ottieni il punto", "Vai a sito di…", "Premi già ottenuti" |

## Data / API

- Benefits list, detail, and code redemption are **not documented** — see [[missing-apis]]
  (§6). Codes/redirects point to **external partner sites**, not in-app commerce
  (see [[missing-informations]]).

## Implementation notes

- Feature placement: `features/benefits/presentation/`.
- Open partner links in an external browser / custom tab.

## Routing

`/benefits` → `/benefits/{id}`.

## Related

- [[navigation]]
- [[missing-apis]]
- [[missing-informations]]
- [[README]]
