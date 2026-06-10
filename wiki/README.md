# Kilocal API Wiki

Knowledge base derived from **KILOCAL — Documentazione API pubbliche** (v1.0, 1 giugno 2026).
Source document: `raw/KILOCAL DOCUMENTAZIONE TECNICA .pdf`.
Project: `kilocal-shop-fe` (Nuxt frontend) + CMS extension `shop-apis`.

## Summary

The Kilocal shop frontend (Nuxt) exposes two layers of browser-accessible APIs plus utility
routes:

| Layer | Base URL | Page |
|-------|----------|------|
| Shop API | `{SHOP_URL}/api/*` | custom endpoints for cart, orders, users, addresses, PayPal |
| CMS Proxy | `{SHOP_URL}/cms/*` | proxy to Directus (auth, GraphQL, REST, assets) |
| Utility routes | `{SHOP_URL}/finder`, `{SHOP_URL}/logout` | internal routing and logout |

- Responses are JSON, except redirects on `/finder` and `/logout`.
- CORS is restricted to configured origins (`SHOP_URL`, `MAIN_URL`, `PUBLIC_URL`, PayPal).
- Example production URLs: Shop `https://shop.kilocalprogram.it`, CMS `https://cms.kilocalprogram.it`.

## Wiki layout & link convention

> **For agents/LLMs reading this wiki.** Pages link to each other by **name** using
> `[[page-name]]` (the file's basename without `.md`), independent of folder. Resolve a
> `[[name]]` to its file via the index below — every page name is unique across the wiki.
> This `README.md` is the only file that uses real relative paths, so it doubles as the
> name → path map. When adding a page, give it a unique kebab-case name, link it with
> `[[name]]`, and add one index line here.

Folder map:

```
wiki/
  *.md                       API + architecture + design pages (root)
  missing-*.md               gap notes (Italian; rest of the wiki is English)
  flow-screen/*.png          Figma flow screenshots that screen pages describe
  screens/
    onboarding/  screen-splash, screen-onboarding, screen-login, screen-survey
    app/         navigation, screen-home, screen-path, screen-diary, screen-benefits,
                 screen-statistics, screen-momenti, screen-notifications, screen-profile
```

## Entity pages

- [overview](overview.md) — architecture, layers, base URLs, CORS
- [authentication](authentication.md) — session cookies, login, logout, access levels
- [settings](settings.md) — global shop configuration
- [cart](cart.md) — cart lifecycle, items, discounts, addresses
- [cart-data-model](cart-data-model.md) — shape of the cart response object
- [orders](orders.md) — order create/update
- [paypal](paypal.md) — PayPal checkout order creation
- [users](users.md) — registration and password reset
- [user-addresses](user-addresses.md) — address CRUD
- [finder](finder.md) — CMS page URL resolution
- [cms-proxy](cms-proxy.md) — Directus proxy
- [shop-apis-refresh](shop-apis-refresh.md) — internal cart-refresh endpoint

## Client architecture

- [flutter-architecture](flutter-architecture.md) — Flutter app architecture plan (BLoC, feature-first, Dio) consuming the API above

## Design & screens

Derived from the Figma file **KILOCAL-PROGRAM** (`figma.com/design/wvV8JURTECntVCsHl5sNLc`).

- [design-system](design-system.md) — brand colors, gradient, imagery, layout tokens
- [navigation](screens/app/navigation.md) — bottom-bar shell (5 tabs) + modal/sheet patterns

### Onboarding flow

- [screen-splash](screens/onboarding/screen-splash.md) — launch / splash screen
- [screen-onboarding](screens/onboarding/screen-onboarding.md) — post-splash sales-speech carousel
- [screen-login](screens/onboarding/screen-login.md) — login / sign up
- [screen-survey](screens/onboarding/screen-survey.md) — initial/final survey + proof of purchase

### Program app (in-shell)

- [screen-home](screens/app/screen-home.md) — home / hero
- [screen-path](screens/app/screen-path.md) — il tuo percorso + hubs (training, nutrition, wellbeing, integration, materials)
- [screen-diary](screens/app/screen-diary.md) — diary & achievements
- [screen-benefits](screens/app/screen-benefits.md) — partner benefits & discount codes
- [screen-statistics](screens/app/screen-statistics.md) — monthly activity statistics
- [screen-momenti](screens/app/screen-momenti.md) — editorial / challenge content
- [screen-notifications](screens/app/screen-notifications.md) — notification center
- [screen-profile](screens/app/screen-profile.md) — profile & body silhouette

> Screen pages are derived from the Figma flow screenshots in `wiki/flow-screen/`.

## Contradictions & inconsistencies

There is only **one** source document, so no cross-paper contradictions exist. Internal
inconsistencies found in the document are tracked in [contradictions](contradictions.md).

Gaps between the Figma screens and the documented APIs are tracked (in Italian) in
[missing-informations](missing-informations.md) and [missing-apis](missing-apis.md).
