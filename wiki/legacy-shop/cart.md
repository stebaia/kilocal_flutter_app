# Cart

The cart endpoints manage the shopping cart lifecycle. All operations that return an updated cart
internally trigger the [[shop-apis-refresh]] endpoint to recompute totals. The shape of the
returned cart is documented in [[cart-data-model]].

## Init / retrieve cart

```
POST /api/cart/init
```

- Authentication: **optional** (if logged in, retrieves the user's latest cart)

Body:
```json
{ "storeCartUUID": "uuid-opzionale-del-carrello-salvato" }
```

Logic:
1. If `storeCartUUID` is present, look for a draft/pending cart with that UUID.
2. If the user is logged in, look for their latest active cart.
3. If the anonymous cart belongs to another user → error.
4. If the user has a cart different from the saved one → the saved cart is cancelled.
5. Otherwise create a new cart.

Response 200: full `Carts` object (see [[cart-data-model]]).

| Error | Message |
|-------|---------|
| — | `Mismatch between stored cart and user.` |

> ⚠️ Although [[authentication]] lists the cart as "Public", this endpoint's behavior depends on
> login state. See [[contradictions]].

## Add / update item

```
POST /api/cart/{uuid}/items/upsert
```

- Authentication: **no**

Body:
```json
{
  "entry": { "collection": "products", "item": "123" },
  "quantity": 1,
  "fixQta": false,
  "variant": {
    "variantId": "456",
    "title": "Variante M",
    "barcode": "8001234567890",
    "assetId": "file-uuid"
  },
  "kitVariants": null
}
```

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `entry.collection` | string | yes | `"products"` or `"product_kits"` |
| `entry.item` | string | yes | Product/kit ID |
| `quantity` | number | yes | Desired quantity |
| `fixQta` | boolean | yes | `false` = add to existing qty; `true` = set absolute qty |
| `variant` | object \| null | no | Only for products with variants |
| `kitVariants` | object \| null | no | Variant choices for kits (`Record<productId, KitVariantChoice>`) |

Response 200: updated cart (after totals refresh).

| Error | Message |
|-------|---------|
| — | `Cart not found` |

## Remove item

```
DELETE /api/cart/{uuid}/items/delete
```

Body: `{ "item": "cart_item_id" }`

Response 200: updated cart.

## Apply discount code

```
PATCH /api/cart/{uuid}/discounts/apply
```

Body: `{ "code": "PROMO2026" }`

| HTTP | statusMessage | Description |
|------|---------------|-------------|
| 400 | `Missing required parameters` | Missing code |
| 400 | `DISCOUNT_ALREADY_APPLIED` | Discount already applied |
| 400 | `DISCOUNT_INVALID` | Discount not valid for the cart |
| 400 | `DISCOUNT_MAX_USES_REACHED` | Usage limit reached |
| 404 | `DISCOUNT_NOT_FOUND` | Code does not exist |
| 404 | `Cart not found` | Invalid cart UUID |

## Remove discount code

```
DELETE /api/cart/{uuid}/discounts/delete
```

Body: `{ "code": "PROMO2026" }`

| HTTP | Message |
|------|---------|
| 400 | `Missing required parameters` |
| 404 | `Cart not found` |
| 404 | `Discount not found` |

## Store addresses on cart

```
PATCH /api/cart/{uuid}/addresses/store
```

Body:
```json
{
  "delivery": { "id": "address-uuid" },
  "invoice": { "id": "address-uuid" }
}
```

`invoice` is optional; if omitted, the shipping address is used.

Response 200: updated cart with computed shipping.

## Related

- [[cart-data-model]]
- [[shop-apis-refresh]]
- [[orders]]
- [[user-addresses]]
- [[authentication]]
