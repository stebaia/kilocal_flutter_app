# Authentication (legacy shop)

> ⚠️ **LEGACY — sistema diverso.** Auth dello **shop e-commerce Nuxt**, basata su **cookie di
> sessione**. **L'app mobile usa Bearer JWT** — vedi [[authentication]]. Riferimento storico.

Session state is held in cookies set by Directus. Login does **not** go through `/api/*`; it
uses the Directus SDK over the [[legacy-shop/cms-proxy|cms-proxy]].

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
| Public | Cart (init, items, discount), [[legacy-shop/settings|settings]], registration, password reset |
| Authenticated | [[legacy-shop/orders|orders]], [[legacy-shop/user-addresses|addresses]], [[legacy-shop/paypal|paypal]] |
| Server only | Internal CMS calls using `CMS_TOKEN` |

## Related

- [[legacy-shop/cms-proxy]]
- [[legacy-shop/users]]
- [[legacy-shop/overview]]
- [[authentication]]
