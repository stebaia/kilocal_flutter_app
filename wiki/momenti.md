# Momenti (GraphQL read)

Collection `moments` — editorial / challenge content with a visibility window
`starts_on` / `ends_on`. Read via [[graphql]]. Source: Swagger *Kilocal App*.

## Tabs (filters)

Substitute `$NOW` with the current ISO 8601 datetime client-side.

| Tab | Filter |
|-----|--------|
| In corso | `starts_on <= $NOW` **and** `ends_on >= $NOW` |
| Passati | `ends_on < $NOW` |
| Futuri | `starts_on > $NOW` |

```json
{
  "filter": {
    "_and": [
      { "starts_on": { "_lte": "2026-06-16T12:00:00" } },
      { "ends_on": { "_gte": "2026-06-16T12:00:00" } }
    ]
  }
}
```

## Query

```graphql
query GetMoments($filter: moments_filter) {
  moments(filter: $filter, sort: ["-starts_on", "-ends_on"]) {
    id
    starts_on
    ends_on
    translations { languages_code { code } title description plot }
    asset { id }
    ctas { id }
  }
}
```

Useful fields: `translations` (title, description, plot), `asset`, `ctas`.

## Resolves missing-apis §7

Replaces the proposed `GET /api/moments` in [[missing-apis]] §7.

## Related

- [[graphql]]
- [[missing-apis]]
