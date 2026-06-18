> ⚠️ **LEGACY — sistema diverso.** Questa pagina descrive lo **shop e-commerce Nuxt**
> (`kilocal-shop-fe`), derivato dal PDF `raw/KILOCAL DOCUMENTAZIONE TECNICA.pdf`. **Non è
> l'API dell'app mobile.** L'app mobile usa il CMS Directus con Bearer JWT — vedi
> [[overview]] e lo Swagger `/api/docs` (tab *Kilocal App*). Autenticazione qui via **cookie
> di sessione**, base URL `{SHOP_URL}`; nell'app mobile via **Bearer token**, base URL
> `https://cms-stg.kilocal.thefullproject.it`. Mantenuta solo come riferimento storico.

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
