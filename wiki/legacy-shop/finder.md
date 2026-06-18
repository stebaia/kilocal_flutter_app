> ⚠️ **LEGACY — sistema diverso.** Questa pagina descrive lo **shop e-commerce Nuxt**
> (`kilocal-shop-fe`), derivato dal PDF `raw/KILOCAL DOCUMENTAZIONE TECNICA.pdf`. **Non è
> l'API dell'app mobile.** L'app mobile usa il CMS Directus con Bearer JWT — vedi
> [[overview]] e lo Swagger `/api/docs` (tab *Kilocal App*). Autenticazione qui via **cookie
> di sessione**, base URL `{SHOP_URL}`; nell'app mobile via **Bearer token**, base URL
> `https://cms-stg.kilocal.thefullproject.it`. Mantenuta solo come riferimento storico.

# Finder

Utility route that resolves CMS page URLs.

```
GET /finder?p={internal_name}&l={locale}&params[slug]={value}
```

| Parameter | Description |
|-----------|-------------|
| `p` | Internal CMS page name (e.g. `shop_single_product`, `shop-account`) |
| `l` | Locale (e.g. `it`, `it-IT`) — default `it` |
| `params[key]` | Parameters interpolated into the slug (e.g. `params[slug]=nome-prodotto`) |

## Behavior

- With `Accept: application/json` → `{ "path": "/percorso-risolto" }`
- Otherwise → HTTP 302 redirect to the resolved path
- If `p` is missing → redirect to `/`

### Example

```
GET /finder?p=shop_single_product&params[slug]=kit-base-uomo
→ 302 /kit-base-uomo
```

## Related

- [[cms-proxy]]
- [[overview]]
