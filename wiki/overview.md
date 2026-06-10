# Overview

The `kilocal-shop-fe` frontend (Nuxt) exposes two levels of browser-accessible APIs plus a set
of utility routes.

## API layers

| Layer | Base URL | Description |
|-------|----------|-------------|
| Shop API | `{SHOP_URL}/api/*` | Custom endpoints for cart, orders, users, addresses, PayPal |
| CMS Proxy | `{SHOP_URL}/cms/*` | Proxy to Directus (auth, GraphQL, REST, assets) |
| Utility routes | `{SHOP_URL}/finder`, `{SHOP_URL}/logout` | Internal routing and logout |

## Environment URLs (production example)

- Shop: `https://shop.kilocalprogram.it`
- CMS: `https://cms.kilocalprogram.it`

## Response format

JSON (`Content-Type: application/json`), except for redirects on `/finder` and `/logout`.

## CORS

Allowed only from configured origins: `SHOP_URL`, `MAIN_URL`, `PUBLIC_URL`, and PayPal.

## Related

- [[authentication]]
- [[cms-proxy]]
- [[finder]]
- [[README]]
