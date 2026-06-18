# Legacy shop — internal inconsistencies

> ⚠️ **LEGACY.** Internal inconsistencies found within the single shop source document
> (`raw/KILOCAL DOCUMENTAZIONE TECNICA.pdf`, v1.0). About the **Nuxt shop e-commerce**, not the
> mobile app. For app-vs-shop contradictions see [[contradictions]].

## 1. Cart "Public" vs login-dependent behavior

[[legacy-shop/authentication]] classifies the cart (init, items, discount) as **Public**, but
[[legacy-shop/cart]] marks auth as optional and branches on login (can error on
`Mismatch between stored cart and user.`). "Public" is imprecise.

## 2. Duplicate `400 Cart not found` on orders

[[legacy-shop/orders]] lists two overlapping `400`s: `Cart not found or missing in payload`
and `Cart not found`. Unclear when each applies.

## 3. Inconsistent error-message style

| Logical error | Variant A | Variant B |
|---------------|-----------|-----------|
| Password mismatch | `Passwords do not match` | `PASSWORDS_DO_NOT_MATCH` |
| Missing email | `Email is required` | `EMAIL_REQUIRED` |
| Cart not found | `Cart not found` | `CART_NOT_FOUND` |

## 4. Mixed-language error messages

Most `statusMessage` values are English; [[legacy-shop/paypal]] returns a `401` in Italian
(`Sessione scaduta…`).

## 5. Settings error has no status code

[[legacy-shop/settings]] returns `{ "settings": {} }` on error with no HTTP error status.

## Related

- [[contradictions]]
- [[legacy-shop/cart]]
- [[legacy-shop/orders]]
