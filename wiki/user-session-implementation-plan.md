# User session — implementation plan

Plan for fetching and caching the authenticated user after login. Covers the two
post-login reads — `GET /users/me` (REST) and `GetUserDetails` (GraphQL) — plus
`profile_status`-driven routing.

Sources: [[user-current]], [[profilo-read]], [[authentication]], [[graphql]], [[errors]].

## Goal

After a successful login **or** at app restart with a valid token:

1. Call `GET /users/me` to obtain and cache `myId` (the Directus user `id`).
2. Run the `GetUserDetails` GraphQL query (`myId` as variable) to load
   `user_details` / `profile_status`.
3. Use `profile_status` to decide the post-login route.

> `myId` is the variable used by most GraphQL profile/percorso queries — fetch it
> once after login and cache it ([[user-current]]).

## Current state

| Area | Status |
|------|--------|
| Auth (`AuthApi`, `AuthRepositoryImpl`, `TokenStore`, `AuthInterceptor` w/ refresh, `LoginCubit`) | ✅ done — `LoginCubit` emits `success` only |
| `GET /users/me` | ❌ missing |
| GraphQL client (`POST /graphql`) | ❌ missing — no GraphQL layer at all |
| `myId` / `user_details` cache | ❌ missing |
| Splash routing | ⚠️ decides on `hasSession` only → `/home` vs `/onboarding` |

## Design decisions

- **`GET /users/me`** → new Retrofit client `UserApi`, returns the `id` = `myId`.
- **`GetUserDetails`** → generic `GraphqlClient` doing a raw `POST /graphql` via the
  existing `Dio` (no GraphQL package — see [[graphql]]; reuses `AuthInterceptor`).
- New **`user` feature** (Clean Architecture: data / domain / presentation) with a
  session-wide `UserCubit` registered as a **lazy singleton** (not a factory) that
  caches `myId`, base user data and `user_details` / `profile_status`.
- **`profile_status`** drives content gating and the post-login route.

### Trigger: Splash + Login

Session load runs in **both** entry paths:

- **`SplashCubit`** — on restart, if `hasSession`, load the user session before
  choosing the route.
- **`LoginCubit`** — after a successful login, trigger the session load, then route.

### Routing on `profile_status`

| `profile_status` | Route |
|------------------|-------|
| `initial_survey`, `type_survey` | `/survey` |
| `active`, `qr_pharmacy_1`, `qr_pharmacy_2` | `/home` |
| `active_restricted_access` | `/home` with tools blocked (`is_tool_blocked`) |
| `starter_kit` | TBD — confirm against wiki during implementation |

> Endpoint auth ≠ content access. Gating is driven by `profile_status` in
> `user_details` plus server-side CMS filters ([[authentication]]).

## Steps

### 1. `GraphqlClient` (core)
`lib/core/network/graphql_client.dart`
- `Future<Map<String, dynamic>> query(String query, {Map<String, dynamic> variables})`
  → `POST /graphql` via the existing `Dio`.
- **HTTP 200 even on errors** — always inspect the `errors` array and map to
  `ApiException` ([[errors]], [[graphql]]).

### 2. Feature `user` — data
`lib/features/user/data/`
- `UserApi` (Retrofit): `@GET('/users/me')` with
  `fields=id,email,first_name,last_name,role.name`; DTO `CurrentUserDto`.
- `UserDetailsDto` — parses the `user_details` node from the GraphQL result.
- `UserRepositoryImpl`: `fetchCurrentUser()` (REST) + `fetchUserDetails(myId)` (GraphQL).

### 3. Feature `user` — domain
`lib/features/user/domain/`
- Entities `AppUser` (id, email, name) and `UserDetails` (profileStatus, gender,
  weight, height, percorso steps).
- `UserRepository` interface.
- Enum `ProfileStatus` with the 7 documented values + `unknown` fallback.

### 4. Feature `user` — presentation
`lib/features/user/presentation/cubit/`
- `UserCubit` (**lazy singleton**): `loadSession()` (users/me → cache `myId` →
  `GetUserDetails`), exposes user + details + status; `clear()` on logout.

### 5. Routing on `profile_status`
`lib/app/router.dart` + splash/login
- `SplashCubit`: if `hasSession` → `UserCubit.loadSession()` → route from `profile_status`.
- `LoginCubit`: after `success` → `loadSession()` → navigate by status.
- `logout()` → also call `UserCubit.clear()`.

### 6. DI
`lib/app/di.dart` — register `GraphqlClient`, `UserApi`, `UserRepository`, and
`UserCubit` (singleton).

### 7. Verify
- `dart run build_runner build` for the `.g.dart` (Retrofit/json_serializable).
- `dart analyze`.
- Unit test on `ProfileStatus` → route mapping.

## Flow summary

1. `POST /auth/login` (`mode: json`) → access + refresh token (already implemented).
2. `GET /users/me` → fetch and cache `id` (= `myId`).
3. GraphQL `GetUserDetails($myId)` → `user_details` + `profile_status`.
4. Route from `profile_status` (survey / home / restricted).

## Related

- [[user-current]]
- [[profilo-read]]
- [[authentication]]
- [[graphql]]
- [[errors]]
- [[auth-implementation-plan]]
- [[flutter-architecture]]
