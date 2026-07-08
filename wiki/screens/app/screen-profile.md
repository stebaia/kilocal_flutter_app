# Screen — Profile & Silhouette

User profile, body type, and body silhouette. Sources: `wiki/flow-screen/profilo1.png`
(Profilo + Tipo + Silhouette + info), `profilo2.png` (voci testo), `profilo3.png`
(Silhouette — 7 types). Reached from the shell — see [[navigation]].

## Purpose

Show and edit the user's profile, present their **biotype/body type** and an interactive
**body silhouette** highlighting affected body parts, with informational text sheets and
external redirects.

## Screens

| Screen | Source | Contents |
|--------|--------|----------|
| **Profile** (Profilo) | `profilo1` | Profile header, type, content cards, "Parte interessata" sheets, info drawers, external redirect |
| **Body type** (Tipo) | `profilo1` | Body figure with type classification |
| **Silhouette** | `profilo3` | **7 silhouette/biotype variants** (Tipo 1…7), each a colored body figure with selectable body parts |
| **Text entries** (Profilo — voci testo) | `profilo2` | Informational/product cards (e.g. "About Skin care") |

## Data / API

- Profile read via GraphQL `GetUserDetails`, write via `PATCH /profile` ([[profilo-read]],
  [[profilo]]). Authentication via [[authentication]].
- **Open BE/design gaps** ([[open-gaps-be-design]]): biotype **texts** (§5, auth-gated
  `profiles_translations`), **change profile image** API (§7, no app endpoint), and the menu
  voices with no Figma/API — Tutorial, Contatta assistenza, Valuta app, Privacy, Termini (§6).

## Implementation notes

- Feature placement: `features/profile/presentation/`.
- The silhouette is an interactive figure (tappable body regions); consider an SVG/asset with
  hit regions per the 7 types.

## Routing

`/profile` → `/profile/silhouette`.

## Related

- [[navigation]]
- [[authentication]]
- [[missing-apis]]
- [[README]]
