> ⚠️ **LEGACY — sistema diverso.** Questa pagina descrive lo **shop e-commerce Nuxt**
> (`kilocal-shop-fe`), derivato dal PDF `raw/KILOCAL DOCUMENTAZIONE TECNICA.pdf`. **Non è
> l'API dell'app mobile.** L'app mobile usa il CMS Directus con Bearer JWT — vedi
> [[overview]] e lo Swagger `/api/docs` (tab *Kilocal App*). Autenticazione qui via **cookie
> di sessione**, base URL `{SHOP_URL}`; nell'app mobile via **Bearer token**, base URL
> `https://cms-stg.kilocal.thefullproject.it`. Mantenuta solo come riferimento storico.

# Cart Data Model

After `init` / `upsert` / `delete` / apply-discount, the response follows the GraphQL `Cart`
schema. Returned by the [[cart]] endpoints and produced by [[shop-apis-refresh]].

| Field | Type | Description |
|-------|------|-------------|
| `uuid` | string | Public cart identifier |
| `subtotal` | number | Products subtotal |
| `subtotal_no_discount` | number | Subtotal without discounts |
| `total` | number | Final total |
| `total_no_discount` | number | Total without discounts |
| `total_items` | number | Item count |
| `shipping_cost` | number | Shipping cost (discounted) |
| `shipping_no_discount` | number | Full shipping cost |
| `shipping` | object | Selected shipping method |
| `items[]` | array | Cart lines (product/kit, qty, prices) |
| `discounts[]` | array | Applied discounts |
| `discounts_raw` | object | Per-product/order discount detail |
| `user_created` | object | Owning user (if logged in) |

## Related

- [[cart]]
- [[shop-apis-refresh]]
- [[orders]]
