# Preferiti (GraphQL read + write)

Collection `user_favourites` + M2A relation `user_favourites_content`. One of the few domains
where **both read and write are GraphQL** (toggle has no business logic). Via [[graphql]].
Fields verified against the SDL. Source: Swagger *Kilocal App*.

## Saveable content types

`articles`, `percorsi_content`, `percorsi_materials`, `pharmacies` (the M2A `content.collection`).

## Active list

Filter `removed_on: { "_null": true }`. Tabs by content type:

| Tab | Filter `content.collection` |
|-----|------------------------------|
| Magazine | `_eq: articles` |
| Percorso | `_or: percorsi_content, percorsi_materials` |
| Farmacie | `_eq: pharmacies` |

## Fields (`user_favourites`)

`id`, `created_on`, `removed_on`, `updated_on`, `user`, `content { … }` (M2A).

## Toggle (mutation, not hard delete)

- New favourite → `create_user_favourites_item`.
- Remove / restore → `update_user_favourites_item` with `removed_on`:
  ISO datetime = removed, `null` = restored.

> **Never hard-delete.** Soft delete via `removed_on` keeps history.

## Resolves

Not in the original [[missing-apis]] (favourites weren't enumerated) — documented here for
completeness, referenced by the Swagger as `preferiti-apis.md`.

## Related

- [[graphql]]
- [[percorso-read]]
