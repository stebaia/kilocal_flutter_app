# Percorso — read (GraphQL)

Read side of the percorso: structure, groups, steps. Start/complete → REST [[percorso]]. Via
[[graphql]]. Source: Swagger *Kilocal App*.

> Visible percorsi are **filtered server-side** by profile type + gender. The app does not
> filter — it renders what GraphQL returns. This is the content-access model (see
> [[authentication]]), resolving [[missing-apis]] §2bis.

## Roots

Root `internal_name`: `allenamento`, `alimentazione`, `benessere`, `integrazione`.
(`integrazione` uses phases, not steps → [[integrazione]].)

## Typical queries

| Query | Use |
|-------|-----|
| `percorsi` + timeframe + user activities | home dashboard |
| `percorsi_groups` filtered by `percorsi_id.root.internal_name` | a percorso's tabs |
| `percorsi_content` by `group` | steps of a group |

Current steps live in `user_details`: `percorso_allenamento_curr_step`,
`percorso_alimentazione_curr_step`, `percorso_benessere_curr_step`, `active_timeframe`
(see [[profilo-read]]).

`stepId` for [[percorso|`/path/steps/*`]] = a `percorsi_content` record id.

> ⚠️ `moments`, `percorsi`, `percorsi_groups`, `percorsi_content`, `timer` are **not in the
> public GraphQL SDL** (`/server/specs/graphql/items`) — they require an authenticated role.
> Field lists here come from the Swagger spec, not the public SDL.

## Resolves missing-apis §2, §2bis, §3

Replaces proposed `GET /api/program/status`, `GET /api/path*`, and the entitlements question.

## Related

- [[percorso]]
- [[integrazione]]
- [[profilo-read]]
- [[graphql]]
- [[missing-apis]]
