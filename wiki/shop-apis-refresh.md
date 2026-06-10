# shop-apis Refresh (internal CMS API)

An endpoint on the CMS, **not** called directly by the browser but by the shop server during cart
refresh. Part of the `shop-apis` CMS extension.

```
POST {CMS_URL}/shop-apis/{cartUUID}/refresh
Content-Type: application/json

{
  "query": "...GraphQL GetCart...",
  "variables": { "filter": { "uuid": { "_eq": "{cartUUID}" } } }
}
```

## Function

1. Recompute cart totals (subtotal, shipping, discount).
2. Apply automatic discounts.
3. Update the `carts` record in Directus.
4. Return the full cart via GraphQL (see [[cart-data-model]]).

Called internally by every [[cart]] operation that returns the updated cart.

## Related

- [[cart]]
- [[cart-data-model]]
- [[cms-proxy]]
