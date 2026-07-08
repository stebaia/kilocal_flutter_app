# Integrazione (GraphQL read + write)

Separate logic from the other percorsi: advancement is by **product phases**, not steps. Via
[[graphql]]. Fields verified against the SDL. Source: Swagger *Kilocal App*.

> ⚠️ **Does NOT use** [[percorso|`/path/steps/*`]]. Phase advancement is a GraphQL mutation.

## Collections

| Collection | Use |
|------------|-----|
| `kit_products` | kit products with `phase`, gender-filtered if `only_for_gender` |
| `user_integratori` | daily tracking (`took_dates`, `delay_days`, `expected_to_end_on`) |
| `products` | catalog, barcode unlock |
| `product_phases` | phase definitions (`id`, `sort`, `translations`) |

### `user_integratori` fields

`id`, `product`, `kit`, `started_on`, `ended_on`, `expected_to_end_on`, `delay_days`,
`took_dates` (JSON array), `user`.

### `kit_products` fields

`id`, `kit`, `phase`, `only_for_gender` (fill only if gender-specific), `sort`,
`products_with_duration`.

`products_with_duration` is an **M2M junction**: each row nests the real data under
`kit_products_duration_id` → `{ id, duration (Int, days), quantity (Int),
product { id title use_for_barcode_check asset { id } } }`. Verified live on cms-stg
(kit 3, 2026-07-06).

### Phase read + advance (verified)

- **Phases for the user's kit:** `kit_products(filter:{kit:{id:{_eq:$kitId}}}, sort:["sort"])`.
  Filter var type is `GraphQLStringOrFloat!`. Sort by `phase.sort` (populated; the
  `kit_products.sort` and `product_phases.sort` at top level are often null).
- **Current phase:** `user_details.percorso_integrazione_curr_phase { id sort translations }`
  (already wired in the user repo); `null` until started.
- **Advance:** `update_user_details_item(data:{ percorso_integrazione_curr_phase: $phaseId })`
  — input field is typed **`Int`**, not `ID`.
- `users_me` does NOT exist in GraphQL; resolve the user via `user_details` filtered by
  `user.id`.

> **Status:** read path implemented in `lib/features/integrazione/` (phases + products UI,
> `/path/integrazione` routes to `IntegrazioneScreen` instead of the steps endpoint that
> 400s). Daily intake tracking (`user_integratori.took_dates`) and barcode unlock still TODO.

> ⚠️ **Detail-screen images** don't map cleanly: only `product.asset { id }` is confirmed, but
> the Figma detail needs hero/instruction imagery. BE gap — see [[open-gaps-be-design]] §4.

## Flows

- **Take a supplement:** `create_user_integratori_item` / `update_user_integratori_item`
  (append today to `took_dates`).
- **Advance phase:** `update_user_details_item` with `percorso_integrazione_curr_phase`.
- **Barcode unlock:** query `products` with `use_for_barcode_check: true`, validate
  **client-side** against `barcodes` / `variants.barcodes`, then run survey/profile.
  (`products`: `id`, `title`, `barcodes`, `use_for_barcode_check`, `variants { barcodes }`.)
  - Verified live 2026-07-08 on cms-stg: `barcodes[].codice` are `A` + 9 digits (e.g.
    `A947328593`). `products_translations` carries `title`, `instructions`, `timing`,
    `description`, `avvertenze` → feeds the unlock bottom-sheet copy (product name +
    instructions). Match = codice `_eq` on `products[].barcodes[].codice` OR
    `variants[].barcodes[].codice`.
  - **OPEN (BE):** the *effect* of a valid match is undocumented. After validation what
    do we write to lift `active_restricted_access`? (a `update_user_details_item` field?
    a dedicated mutation/endpoint?) Blocks the "Sblocca il programma" sheet's unlock call.
    See [[restricted-access-path-gating]].

## Resolves missing-apis §1.2, §3.2

Proof-of-purchase / barcode unlock (§1.2) is client-side barcode validation, not a
`POST /api/proof-of-purchase`. Integration hub (§3.2 `percorso5`) is this domain.

## Related

- [[percorso-read]]
- [[profilo-read]]
- [[graphql]]
- [[missing-apis]]
