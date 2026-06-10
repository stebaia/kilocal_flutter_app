# Authentication

Session state is held in cookies set by Directus. Login does **not** go through `/api/*`; it uses
the Directus SDK over the [[cms-proxy]].

## Session cookies

| Cookie | Description |
|--------|-------------|
| `klkl-data` | Directus session token (access + refresh) |
| `klkl_refresh_token` | Refresh token |

- Duration: **7 days**
- `SameSite: lax`, `Secure` in production
- Authenticated requests must use `credentials: 'include'`

## Login

```
POST {SHOP_URL}/cms/auth/login
Content-Type: application/json

{ "email": "utente@example.com", "password": "********" }
```

After login, authenticated calls automatically send `Authorization: Bearer {access_token}`
(handled by the Directus client).

## Logout

```
GET {SHOP_URL}/logout
```

Invalidates session cookies and redirects to `/?logout=true`.

## Access levels

| Level | Endpoints |
|-------|-----------|
| Public | Cart (init, items, discount), [[settings]], registration, password reset |
| Authenticated | [[orders]], [[user-addresses]], [[paypal]] |
| Server only | Internal CMS calls using `CMS_TOKEN` (not exposed to the client) |

> ⚠️ See [[contradictions]] — the "Public" classification of the cart conflicts with cart logic
> that branches on whether the user is logged in.

## Related

- [[cms-proxy]]
- [[users]]
- [[overview]]
