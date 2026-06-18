# Registration & password (Kilocal)

Public routes from the `survey` extension. **No bearer token.** Always send `origin: app`.
Source: Swagger *Kilocal App* (`/api/auth/*`).

## `POST /api/auth/register`

Body:

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `email` | string (email) | ✓ | |
| `password` | string | ✓ | |
| `password_confirm` | string | ✓ | must match `password` |
| `first_name` | string | ✓ | |
| `last_name` | string | ✓ | |
| `origin` | `app` | — | default `app` |
| `newsletter` | boolean | — | |
| `is_from_qr` | boolean | — | user came from a QR campaign |
| `qr_campaign_code` | string \| null | — | QR campaign code |

Responses:

- `200` → `{ id, email, first_name, last_name }`
- `400` → bad payload ([[errors|BadRequest]])
- `409` → email already registered

## `POST /api/auth/password-forgotten`

Body: `{ email, origin: "app" }`. Always returns `200 { status: "ok" }` (does **not** reveal
whether the email exists). `400` on bad payload.

## `POST /api/auth/password-reset`

Body: `{ token, password, password_confirm, origin: "app" }` — `token` arrives by email.
`200 { status: "ok" }` on success, `400` on bad payload.

## Newsletter (standalone)

`POST /api/newsletter/subscribe` — public, body `{ email }` → `200 { success: true }`.

## Related

- [[authentication]]
- [[errors]]
- [[overview]]
