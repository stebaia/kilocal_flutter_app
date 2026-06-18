# Home — implementation plan

Plan for wiring the home screen (`features/home/`) to the backend, replacing the
current `MockDataFactory.homeData` placeholder with real GraphQL reads.

Sources: [[graphql]], [[percorso-read]], [[diario-attivita]], [[profilo-read]],
[[user-current]], [[screen-home]], [[user-session-implementation-plan]].

## Goal

When the home tab opens, load and render:

1. **Header** — greeting + user name (already in session via `UserCubit`) + today's date (client-side).
2. **Continua il percorso** card — title / image / CTA label of the step to resume.
3. **Progresso mese** card — month label, description text, and the **progress %** for the current month.
4. **Action cards** — Momenti and Benefit tiles.

All reads go through `POST /graphql` (existing `GraphqlClient`). No new REST endpoints.

## Backend contract (confirmed with team, 2026-06-18)

| Element | Source |
|---------|--------|
| Continua percorso — title / image | `user_activities` + `percorsi_content` (last resumable step) |
| Continua percorso — CTA label | `private_pages` → section `private_sec_hero` → `cta_continue_label` |
| Mese corrente (label) | `user_details.active_timeframe` |
| Descrizione mese | `private_pages` → section `private_sec_charts` → `month_text` |
| Progresso % | computed app-side: completed vs total steps of current month |
| Momenti | `moments` (filter `starts_on ≤ $NOW ≤ ends_on`) |
| Benefit | `partners` (`main_partner: true` = hero, `false` = list) |

### Progress % — the one computation

- **Current month** = `user_details.active_timeframe` (maps to `percorsi_timeframes.sort` = 1, 2 or 3).
- **Total (denominator)** = count of percorso steps where `percorsi_timeframes.sort` == current month.
- **Completed (numerator)** = count of `user_activities` for those steps with `completed_on` **not null**.
- `progress = completed / total` (0..1). Guard `total == 0` → `0`.

### Step status (from `user_activities`) — reused beyond the home

- `completed_on` set → **completed**
- only `started_on` set → **started, not completed**
- no row → **not started**

### "Continua il percorso" — data source decision

The card title/image come **from the backend** (`user_details.percorso_*_curr_step`, or the
`user_activities` with `completed_on: null`). We do **not** persist navigation state in the app.

> **Local storage exception:** the video playback position (seconds watched) is **not** stored
> backend-side, so it lives in local storage and is read **only inside the video player**, not on
> the home. The home card needs no local state.

## Open question (before coding)

- **Exact field name** for the current step: the team wrote `user_details.percorso_*_curr_step`
  (the `*` suggests a per-area/phase field, e.g. `percorso_nutrition_curr_step`). Confirm the real
  field name(s) against the GraphQL schema / with the team. → resolves to a single field once known.

## Current state

| Area | Status |
|------|--------|
| `home_screen.dart` + widgets (Header, ContinuePathCard, MonthStatsCard, ActionCardsGrid) | ✅ built, fed by mock |
| `HomeData` / `ContinuePathItem` / `MonthStats` / `HomeActionCard` entities | ✅ exist (domain) |
| `HomeCubit` | ⚠️ only `loadWithData(mock)`; `load()` is a stub |
| `GraphqlClient` (`POST /graphql`) | ✅ exists (core) |
| `UserCubit` (session, `active_timeframe`, user name) | ✅ exists (singleton) |
| Home data layer (API / DTO / repository) | ❌ missing |

## Design decisions

- New **home data layer** (Clean Architecture): `features/home/data/` + `domain/` repository
  interface; presentation already done.
- All reads via the existing **`GraphqlClient`** — queries are plain strings, no GraphQL package
  ([[graphql]]).
- Read `active_timeframe` and user name from the session **`UserCubit`** — do not re-fetch.
- Progress % is computed in the **repository** (or a small mapper), not in the widget.
- Momenti / Benefit are the same collections used by their own screens ([[momenti]],
  [[benefit-partner]]) — reuse those queries/DTOs if/when they exist, otherwise add them here.

## Steps

### 1. Home — domain
`lib/features/home/domain/`
- `HomeRepository` interface: `Future<HomeData> fetchHome({required String myId, required int currentMonth})`.
- Keep existing entities; add a `monthProgress` value if not already covered by `MonthStats.progress`.

### 2. Home — data
`lib/features/home/data/`
- GraphQL queries (strings):
  - `HomeContinueStep` — last resumable step (`user_details.percorso_*_curr_step` → `percorsi_content`) + `private_sec_hero.cta_continue_label`.
  - `HomeMonthProgress` — steps of `percorsi_timeframes.sort == currentMonth` + matching `user_activities` (`completed_on`).
  - `HomeMonthText` — `private_pages` → `private_sec_charts.month_text`.
  - `HomeMoments` — `moments` filtered by `$NOW`.
  - `HomeBenefits` — `partners` (`main_partner`).
- DTOs (`json_serializable`) per query node.
- `HomeRepositoryImpl`: runs the queries, computes `progress = completed / total`, maps to `HomeData`.

### 3. Home — presentation
`lib/features/home/presentation/cubit/`
- `HomeCubit.load()`: read `myId` + `active_timeframe` from `UserCubit`, call repository,
  emit `loaded` / `error`. Drop the mock path once wired.
- `home_screen.dart`: call `cubit.load()` instead of `loadWithData(MockDataFactory.homeData(...))`.

### 4. DI
`lib/app/di.dart` — register `HomeRepository` (+ impl) and switch `HomeCubit` to take it.

### 5. Verify
- `dart run build_runner build` (DTO `.g.dart`).
- `dart analyze`.
- Unit test on the progress computation (completed/total incl. `total == 0`).

## Flow summary

1. Home opens → `HomeCubit.load()`.
2. Read `myId` + `active_timeframe` from `UserCubit`.
3. GraphQL: continue step, month progress, month text, moments, benefits.
4. Compute `progress = completed / total`.
5. Emit `HomeData` → render. (Video resume position stays local, handled later in the player.)

## Related

- [[graphql]]
- [[percorso-read]]
- [[diario-attivita]]
- [[profilo-read]]
- [[user-current]]
- [[screen-home]]
- [[user-session-implementation-plan]]
- [[flutter-architecture]]
