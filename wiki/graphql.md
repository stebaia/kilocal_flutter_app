# GraphQL — CMS reads

`POST /graphql` is the **read** layer of the mobile app: all CMS content is fetched here.
Native Directus GraphQL, bearer token required. **Writes/actions go through the REST
extensions** (see [[overview]] for the split).

> **Flutter client:** raw `POST /graphql` via Dio (the same client used for REST). No
> dedicated GraphQL package — queries are strings, variables are a JSON map.

```
POST /graphql
Authorization: Bearer <access_token>
Content-Type: application/json

{ "query": "…", "variables": { … } }
```

Response: `{ "data": { … }, "errors": [ … ] }`. **`200` even on errors** — always check the
`errors` array. See [[errors]].

Full schema (SDL): `GET /server/specs/graphql/system` (system + custom collections visible to
the role). Some content collections (`moments`, `percorsi*`, `timer`) are only present in the
SDL for authenticated roles.

## Domains

| Domain | Collection / root | GraphQL | REST write |
|--------|-------------------|---------|------------|
| [[momenti]] | `moments` | query | — |
| [[benefit-partner]] | `partners` | query | — |
| [[preferiti]] | `user_favourites` | query + create/update mutation | — (soft delete via `removed_on`) |
| [[notifiche]] | `user_notifications` | query + `update_user_notifications_item` | — |
| [[diario-attivita]] | `user_activities` | aggregated / paginated query | — |
| Diario goals | `user_reminders` | optional query | **[[diario]]** `/journal/goals` |
| [[strumenti-read]] | `timer`, `glossary`, `user_photos`, … | singleton / collection query | reminders, gallery → **[[strumenti]]** |
| [[percorso-read]] | `percorsi`, `percorsi_groups`, `percorsi_content` | query | start/complete → **[[percorso]]** |
| [[integrazione]] | `user_integratori`, `kit_products`, `products` | query + mutation | — (no step complete) |
| [[profilo-read]] | `user_details`, `user_addresses` | `GetUserDetails` | **[[profilo]]** `PATCH /profile` |

## Conventions

- **Translations:** content collections use a `translations { languages_code { code } … }`
  pattern; pick the user locale client-side.
- **Filters:** Directus filter syntax (`_eq`, `_lte`, `_gte`, `_null`, `_nnull`, `_and`,
  `_or`, …). Substitute `$NOW` (ISO 8601) client-side for time windows.
- **Aggregates:** `<collection>_aggregated` with `groupBy` / `count` for badges & grouping.
- **Soft delete:** prefer flag fields (`removed_on`, `archived_on`) over hard delete.

## Related

- [[overview]]
- [[errors]]
- [[authentication]]
