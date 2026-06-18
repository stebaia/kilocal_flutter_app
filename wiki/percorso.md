# Percorso — step start/complete (REST writes)

`path` extension. **Write** side of the percorso: start and complete steps. The **read** side
(percorsi, gruppi, step content) is GraphQL — see [[percorso-read]]. Bearer token required.
Source: Swagger *Kilocal App*.

> Hybrid by design: read the structure via [[graphql]], then call these REST routes to record
> progress. See [[overview]] for the read/write split.

## Endpoints

| Method | Path | Purpose |
|--------|------|---------|
| POST | `/path/steps/{stepId}/start` | start a step → create `user_activity` (idempotent) |
| POST | `/path/steps/{stepId}/complete` | mark a step completed |

`stepId` is the id of the `percorsi_content` record (load it via [[percorso-read]]).

### `POST /path/steps/{stepId}/start`

Idempotent — if an activity already exists for the step it is returned without duplicating.
Call on first open of a step. Returns `{ data: UserActivity }` where `UserActivity` =
`{ id, started_on, completed_on }`.

### `POST /path/steps/{stepId}/complete`

Body: `{ "percorsoInternalName": "allenamento" | "alimentazione" | "benessere" }`.

Updates `user_activities.completed_on`, bumps the matching `percorso_*_curr_step` in
`user_details`, and — if the current timeframe hits 100% — advances `active_timeframe`.

Mapping `percorsoInternalName` → `user_details` field:

| internalName | field |
|--------------|-------|
| `allenamento` | `percorso_allenamento_curr_step` |
| `alimentazione` | `percorso_alimentazione_curr_step` |
| `benessere` | `percorso_benessere_curr_step` |

Response (`PercorsoCompleteResponse`):

```json
{
  "data": {
    "activity": { "id": "…", "started_on": "…", "completed_on": "…" },
    "currStepField": "percorso_allenamento_curr_step",
    "stepId": "…",
    "timeframeAdvanced": true,
    "activeTimeframe": { "id": 3, "sort": 2 }
  }
}
```

`400` bad body · `401` no token · `404` activity or `user_details` not found.

> ⚠️ **`integrazione` does NOT use these routes.** It follows product *phases*, not steps:
> advancement is `update_user_details_item` on `percorso_integrazione_curr_phase` via GraphQL.
> See [[integrazione]].

## Typical flow

1. [[percorso-read|GraphQL]] `GetUserDetails` → current steps + `active_timeframe`.
2. [[percorso-read|GraphQL]] load `percorsi_groups` / `percorsi_content` for the tab.
3. `POST /path/steps/{stepId}/start` on first open.
4. `POST /path/steps/{stepId}/complete` on "Segna come completato".

## Related

- [[percorso-read]]
- [[integrazione]]
- [[diario-attivita]]
- [[overview]]
