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
