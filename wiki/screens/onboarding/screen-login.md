# Screen — Login / Sign up

Authentication entry point. Source: Figma flow `wiki/flow-screen/login.png`
(frame "Log in / sign up"). Backed by the [[authentication]] and [[registration]] APIs
(mobile app — Directus + Bearer JWT, **not** the legacy shop cookie session).

## Purpose

Let the user **log in** (Accedi) or **register** (Registrati). Reached from
[[screen-onboarding]]; on success routes into the app shell ([[navigation]] → [[screen-home]])
or the [[screen-survey]] flow for first-time users.

## Screens

| Screen | Fields | Primary action |
|--------|--------|----------------|
| **Log in** (Accedi) | email, password | "Accedi" → `POST /auth/login` ([[authentication]]) |
| **Sign up** (Registrati) | first name, last name, email, password, password confirm, privacy/newsletter flags | "Registrati" → `POST /api/auth/register` ([[registration]]) |

- A "Password dimenticata?" link starts the forgotten-password flow ([[registration]] →
  `POST /api/auth/password-forgotten`).
- Two visual variants exist in the design (light form and brand-colored form); same fields.

## Data / API

- Login: `POST /auth/login` with `mode: json` → `AuthTokens` (access + refresh in the JSON
  body, stored client-side). See [[authentication]]. **No cookies.**
- Registration: `POST /api/auth/register` with `origin: app` ([[registration]]).
- Forgotten password: `POST /api/auth/password-forgotten` with `origin: app` ([[registration]]).
- After login fetch [[user-current|`GET /users/me`]] (→ `myId`) and
  [[survey|`GET /survey/me/status`]] to decide routing (see below).

## Implementation notes

- Driven by `AuthBloc` (states: unauthenticated / authenticating / authenticated / expired) —
  see [[flutter-architecture]].
- Validate password confirmation client-side; server returns `409` on duplicate email and
  `400` on bad payload ([[registration]], [[errors]]).
- Feature placement: `features/auth/` — needs `data/` (Retrofit `AuthApi` + `AuthTokens` DTO),
  `domain/` (repository), and a real `AuthBloc`/cubit. The current `login_cubit.dart` is a
  **mock** (1s delay), and `env.dart` / `dio_client.dart` / `auth_interceptor.dart` still point
  at the legacy **shop** (`{SHOP_URL}/cms/auth/*`, cookies) — must be rewired to Directus
  (`/auth/*`, Bearer, `mode: json`). See [[authentication]].

## Routing

`/login` (and `/signup`). On success: fetch `GET /users/me` + `GET /survey/me/status`, then
route by `profile_status` — app shell ([[navigation]] → [[screen-home]]) vs the
[[screen-survey]] onboarding.

> ⚠️ **Open:** the exact `profile_status` → home-vs-survey mapping is **not documented**.
> Confirm with the backend team (e.g. which of `initial_survey` / `type_survey` / `active` /
> `active_restricted_access` lands where). See [[missing-apis]].

## Related

- [[authentication]]
- [[registration]]
- [[user-current]]
- [[survey]]
- [[auth-implementation-plan]]
- [[screen-onboarding]]
- [[screen-survey]]
- [[navigation]]
- [[flutter-architecture]]
- [[README]]
