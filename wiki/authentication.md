# Authentication (mobile app)

Source of truth: Swagger **`/api/docs`** → tab *Kilocal App* (`/api/docs/openapi.yaml`,
spec v1.2.1). The mobile app talks **directly to the Directus CMS** with **Bearer JWT** —
**not** the cookie session used by the legacy [[legacy-shop/authentication|shop]].

> For the old cookie-session shop auth see [[legacy-shop/authentication]] (legacy).

## Base URL

| Env | URL |
|-----|-----|
| Staging | `https://cms-stg.kilocal.thefullproject.it` |
| Production | `https://cms.kilocalprogram.it` |
| Local (Docker) | `http://localhost:8055` |

## Flow

1. `POST /auth/login` with `email` / `password` and `mode: json` → returns access + refresh token.
2. Send `Authorization: Bearer <access_token>` on every protected route.
3. `POST /auth/refresh` with the refresh token when the access token expires.
4. `POST /auth/logout` invalidates the refresh token.

> **Always use `mode: json`** from native apps (no cookies). Tokens are returned in the JSON
> body, the app stores them itself.

## Endpoints

| Method | Path | Auth | Notes |
|--------|------|------|-------|
| POST | `/auth/login` | public | body `{ email, password, mode: "json" }` → `AuthTokens` |
| POST | `/auth/refresh` | public | body `{ refresh_token, mode: "json" }` → `AuthTokens` |
| POST | `/auth/logout` | public | body `{ refresh_token, mode: "json" }` → `204` |
| POST | `/api/auth/register` | public | Kilocal registration (see [[registration]]) |
| POST | `/api/auth/password-forgotten` | public | request reset email (always `200`, never reveals if email exists) |
| POST | `/api/auth/password-reset` | public | `{ token, password, password_confirm }` |

> **Two prefixes.** Login/refresh/logout are **native Directus** (`/auth/*`). Registration and
> password flows are the **Kilocal `survey` extension** (`/api/auth/*`) and are public — always
> send `origin: app`.

### `AuthTokens` response shape

```json
{ "data": { "access_token": "…", "refresh_token": "…", "expires": 900000 } }
```

`expires` is the access-token lifetime **in milliseconds**.

## Header (survey/extension routes)

```
X-Kilocal-Origin: app
```

Optional header marking the mobile client on `survey` / extension routes.

## Authorization ≠ content access

Endpoint auth (bearer present/valid) is separate from **content access**. Which percorso
hubs/tools the user sees is driven by **`profile_status`** in `user_details`
(`initial_survey`, `type_survey`, `starter_kit`, `active`, `active_restricted_access`,
`qr_pharmacy_1`, `qr_pharmacy_2`) and by **server-side CMS filters** (profile type + gender).
Tools can be blocked via `is_tool_blocked` (config) when
`profile_status = active_restricted_access`. This resolves the old open question in
[[missing-apis]] §2bis.

## Related

- [[overview]]
- [[registration]]
- [[graphql]]
- [[profilo-read]]
- [[contradictions]]
