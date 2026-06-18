> ⚠️ **LEGACY — sistema diverso.** Questa pagina descrive lo **shop e-commerce Nuxt**
> (`kilocal-shop-fe`), derivato dal PDF `raw/KILOCAL DOCUMENTAZIONE TECNICA.pdf`. **Non è
> l'API dell'app mobile.** L'app mobile usa il CMS Directus con Bearer JWT — vedi
> [[overview]] e lo Swagger `/api/docs` (tab *Kilocal App*). Autenticazione qui via **cookie
> di sessione**, base URL `{SHOP_URL}`; nell'app mobile via **Bearer token**, base URL
> `https://cms-stg.kilocal.thefullproject.it`. Mantenuta solo come riferimento storico.

# Orders

Order creation and update. Requires [[authentication]] (`401` if not logged in).

## Create / update order

```
POST /api/orders/upsert
```

- Authentication: **yes** (`401` if not logged in)

Body (create):
```json
{
  "total": 89.90,
  "cart": "cart-uuid",
  "shipping_address": "address-id",
  "shipping_method": "shipping-id",
  "invoice_address": "address-id"
}
```

Body (update):
```json
{
  "order": "order-uuid",
  "cart": "cart-uuid",
  "total": 89.90,
  "shipping_address": "address-id",
  "shipping_method": "shipping-id",
  "invoice_address": "address-id",
  "status": "pending",
  "paypal_order": { "...": "..." }
}
```

### Response 200

Array containing the created/updated order:
```json
[
  { "uuid": "order-uuid", "status": "draft", "total": 89.90, "paypal_order": null }
]
```

### Errors

| HTTP | statusMessage |
|------|---------------|
| 401 | `Unauthorized` |
| 400 | `Cart not found or missing in payload` |
| 400 | `MISSING_SHIPPING_ADDRESS` |
| 400 | `MISSING_SHIPPING_METHOD` |
| 400 | `Cart not found` |
| 500 | `ORDER_UPSERT_FAILED` |

> ⚠️ Both `Cart not found or missing in payload` and `Cart not found` are listed as distinct
> `400` errors — see [[contradictions]].

## Related

- [[cart]]
- [[paypal]]
- [[user-addresses]]
- [[authentication]]
