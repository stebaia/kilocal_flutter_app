> ⚠️ **LEGACY — sistema diverso.** Questa pagina descrive lo **shop e-commerce Nuxt**
> (`kilocal-shop-fe`), derivato dal PDF `raw/KILOCAL DOCUMENTAZIONE TECNICA.pdf`. **Non è
> l'API dell'app mobile.** L'app mobile usa il CMS Directus con Bearer JWT — vedi
> [[overview]] e lo Swagger `/api/docs` (tab *Kilocal App*). Autenticazione qui via **cookie
> di sessione**, base URL `{SHOP_URL}`; nell'app mobile via **Bearer token**, base URL
> `https://cms-stg.kilocal.thefullproject.it`. Mantenuta solo come riferimento storico.

# Settings

Returns the global shop configuration (menu, strings, footer).

## Get settings

```
GET /api/settings
```

- Authentication: **no**

### Response 200

```json
{
  "settings": {
    "main_menu": { "...": "..." },
    "footer_menu": { "...": "..." },
    "generic_strings": { "...": "..." }
  }
}
```

On error, returns `{ "settings": {} }` (no error status code).

## Related

- [[overview]]
- [[authentication]]
