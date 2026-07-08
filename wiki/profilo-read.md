# Profilo — read (GraphQL)

Read side of the profile. Updates → REST [[profilo]] `PATCH /profile`. Via [[graphql]].
Fields verified against the SDL. Source: Swagger *Kilocal App*.

## `GetUserDetails` query

`myId` comes from [[user-current|`GET /users/me`]].

```graphql
query GetUserDetails($myId: ID!) {
  user_details(filter: { user: { id: { _eq: $myId } } }) {
    id profile_status weight height gender newsletter
    active_timeframe
    percorso_allenamento_curr_step
    percorso_alimentazione_curr_step
    percorso_benessere_curr_step
    percorso_integrazione_curr_phase { id sort translations { languages_code { code } title } }
  }
  user_addresses(filter: { user_created: { id: { _eq: $myId } } }) {
    id address city province zip phone
  }
}
```

## `user_details` — key fields (from SDL)

| Field | Type | Notes |
|-------|------|-------|
| `profile_status` | String | content gating — see [[authentication]] |
| `gender` | String | |
| `weight` / `height` / `bmi` | String | |
| `age` / `date_of_birth` | String / Date | |
| `active_timeframe` | Int | current timeframe |
| `percorso_allenamento_curr_step` | Int | |
| `percorso_alimentazione_curr_step` | Int | |
| `percorso_benessere_curr_step` | Int | |
| `percorso_integrazione_curr_phase` | product_phases | phase (not step) |
| `profile` | profiles | biotype profile |
| `has_kit_purchased` / `has_single_product` | Boolean | |
| `is_platform_user` / `is_shop_user` / `is_from_qr` | Boolean | |
| `allergie` / `intolleranze` / `dieta` | JSON | |
| `newsletter` + `platform_*_accepted` | Boolean | consents |

## `user_addresses` — key fields (from SDL)

`address`, `address_number`, `city`, `province`, `region`, `zip`, `country`, `phone`,
`int_prefix`, `first_name`, `last_name`, `cod_fisc`, plus billing/default flags
(`is_default`, `is_billing_address`, …) and `deleted_at` (soft delete).

> **Silhouette / biotype** (missing-apis §9) derives from `gender` + `profile` + percorso
> fields — no dedicated endpoint. **Biotype texts** (`profiles_translations`) are auth-role
> gated, and **profile-image upload** has no app endpoint — both are BE gaps, see
> [[open-gaps-be-design]] §5 and §7.

## Related

- [[profilo]]
- [[user-current]]
- [[survey]]
- [[graphql]]
