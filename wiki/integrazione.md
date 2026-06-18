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

## Flows

- **Take a supplement:** `create_user_integratori_item` / `update_user_integratori_item`
  (append today to `took_dates`).
- **Advance phase:** `update_user_details_item` with `percorso_integrazione_curr_phase`.
- **Barcode unlock:** query `products` with `use_for_barcode_check: true`, validate
  **client-side** against `barcodes` / `variants.barcodes`, then run survey/profile.
  (`products`: `id`, `title`, `barcodes`, `use_for_barcode_check`, `variants { barcodes }`.)

## Resolves missing-apis §1.2, §3.2

Proof-of-purchase / barcode unlock (§1.2) is client-side barcode validation, not a
`POST /api/proof-of-purchase`. Integration hub (§3.2 `percorso5`) is this domain.

## Related

- [[percorso-read]]
- [[profilo-read]]
- [[graphql]]
- [[missing-apis]]
