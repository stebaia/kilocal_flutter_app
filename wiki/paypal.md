# PayPal

Creates a PayPal Checkout order from an existing cart and order. Requires [[authentication]].

## Create PayPal order

```
POST /api/paypal
```

- Authentication: **yes**

Body:
```json
{ "cartId": "cart-uuid", "orderId": "order-uuid" }
```

Response 200: PayPal Checkout Orders API v2 response (order object with `id`, `status`, `links`,
etc.).

### Errors

| HTTP | statusMessage |
|------|---------------|
| 400 | `MISSING_CART_ID` |
| 400 | `MISSING_ORDER_ID` |
| 401 | `Sessione scaduta. Per favore effettua nuovamente il login.` |
| 404 | `ORDER_NOT_FOUND` |
| 404 | `CART_NOT_FOUND` |

## Related

- [[orders]]
- [[cart]]
- [[authentication]]
