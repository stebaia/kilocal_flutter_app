# Diario — attività / cronologia (GraphQL read)

Collection `user_activities` — completed-step history (the read side of the diary). Goals
themselves are written via REST → [[diario]]. Via [[graphql]]. Fields verified against the SDL.
Source: Swagger *Kilocal App*.

## Group by date

`user_activities_aggregated` with
`groupBy: ["year(started_on)", "month(started_on)", "day(started_on)"]`.

This also backs the **statistiche** screen (per-area activity counts per month) — resolves
the proposed `GET /api/statistics` in [[missing-apis]] §5.

## Day detail (completed steps)

```json
{
  "filter": {
    "_and": [
      { "completed_on": { "_nnull": true } },
      { "activity": { "collection": { "_eq": "percorsi_content" } } }
    ]
  }
}
```

## Fields (`user_activities`)

| Field | Type | Notes |
|-------|------|-------|
| `id` | Int | |
| `started_on` | Date | |
| `completed_on` | Date | null = in progress |
| `user` | relation | |
| `activity` | M2A (`user_activities_activity`) | links to `percorsi_content` etc. |

## Query

```graphql
query GetActivities($filter: user_activities_filter, $page: Int = 1) {
  user_activities(filter: $filter, page: $page, sort: ["-completed_on"]) {
    id started_on completed_on
    activity { item { __typename } }
  }
}
```

> **Goals (traguardi)** are not created/updated here — use [[diario]] `/journal/goals`.

## Resolves missing-apis §4 & §5

History part of §4 (diary entries) and all of §5 (statistics).

## Related

- [[diario]]
- [[percorso]]
- [[graphql]]
- [[missing-apis]]
