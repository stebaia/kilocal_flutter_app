# Contradictions & Inconsistencies

The `raw/` folder contains a **single** source document (`KILOCAL DOCUMENTAZIONE TECNICA .pdf`,
v1.0). There are therefore **no cross-document contradictions** to report. The items below are
**internal** inconsistencies and ambiguities found within that one document — worth resolving
before the docs are treated as authoritative.

## 1. Cart "Public" vs. login-dependent behavior

- [[authentication]] §2.4 classifies the **cart** (init, items, discount) as **Public**.
- [[cart]] §3.2.1 (`/api/cart/init`) marks auth as **optional** and its logic branches on whether
  the user is logged in (retrieves the user's latest cart, can error on
  `Mismatch between stored cart and user.`).

→ "Public" is imprecise: the cart is publicly *reachable* but behaves differently when
authenticated. The access-level table and the endpoint description disagree on framing.

## 2. Duplicate / overlapping `400 Cart not found` on orders

[[orders]] §3.3.1 lists two distinct `400` errors that appear to overlap:

- `Cart not found or missing in payload`
- `Cart not found`

→ Unclear when each is returned, or whether one supersedes the other.

## 3. Inconsistent error-message style across endpoints

Error `statusMessage` values mix human-readable sentences with `SCREAMING_SNAKE_CASE` codes,
sometimes for the same logical error:

| Logical error | Variant A | Variant B |
|---------------|-----------|-----------|
| Password mismatch | `Passwords do not match` ([[users]] registration) | `PASSWORDS_DO_NOT_MATCH` ([[users]] reset) |
| Missing email | `Email is required` (registration) | `EMAIL_REQUIRED` (forgotten password) |
| Cart not found | `Cart not found` ([[cart]], [[orders]]) | `CART_NOT_FOUND` ([[paypal]]) |

→ No single convention; clients cannot reliably switch on message strings.

## 4. Mixed-language error messages

Most `statusMessage` values are English, but [[paypal]] returns a `401` in Italian:
`Sessione scaduta. Per favore effettua nuovamente il login.`

→ Localization of error messages is inconsistent.

## 5. Settings error has no status code

[[settings]] (`/api/settings`) returns `{ "settings": {} }` on error with no documented HTTP
error status, unlike every other endpoint which documents explicit error codes.

→ Callers cannot distinguish "empty config" from "error" via status.

## Related

- [[README]]
- [[authentication]]
- [[cart]]
- [[orders]]
- [[users]]
- [[paypal]]
- [[settings]]
