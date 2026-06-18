# CMS Proxy

All requests to `{SHOP_URL}/cms/{path}` are forwarded to `{CMS_URL}/{path}` (Directus).

## Most-used Directus endpoints

| Method | Path | Use |
|--------|------|-----|
| POST | `/cms/auth/login` | Login |
| POST | `/cms/auth/refresh` | Refresh token |
| POST | `/cms/auth/logout` | Logout |
| POST | `/cms/graphql` | GraphQL query/mutation (content, pages, products) |
| GET | `/cms/items/{collection}` | Directus REST (public/authenticated permissions) |
| GET | `/cms/assets/{id}` | Assets/media |

## Notes

- Effective permissions depend on the Directus role configuration.
- The proxy does **not** add server-side authentication: it uses the user token from the cookie
  if present.

> ℹ️ This is the public-facing proxy. It is distinct from the internal [[shop-apis-refresh]]
> endpoint, which runs server-to-server against the CMS.

## Related

- [[authentication]]
- [[shop-apis-refresh]]
- [[finder]]
- [[overview]]
