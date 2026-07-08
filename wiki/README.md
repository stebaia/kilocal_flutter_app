# Kilocal API Wiki

Knowledge base for the **Kilocal mobile app** API. Primary source: Swagger **`/api/docs`** →
tab *Kilocal App* (`/api/docs/openapi.yaml`, spec v1.2.1) on
`https://cms-stg.kilocal.thefullproject.it`. The app talks **directly to the Directus CMS**
with **Bearer JWT**. Swagger URL + staging credentials + raw-spec fetch: [[swagger]].

> The earlier wiki documented the **Nuxt shop e-commerce** (cookie session) from
> `raw/KILOCAL DOCUMENTAZIONE TECNICA.pdf`. That is a **different system** — moved to
> `wiki/legacy-shop/`. See [[contradictions]].

## The hybrid model

The app uses **both** layers, split by responsibility (see [[overview]]):

- **GraphQL** `POST /graphql` — **reads** all CMS content.
- **REST** extensions (`/auth`, `/survey`, `/path`, `/tools`, `/journal`, `/profile`) —
  **writes** and actions.

Flutter client: GraphQL reads are raw `POST /graphql` via **Dio** (same client as REST).

## Wiki layout & link convention

> Pages link by **name** with `[[page-name]]` (basename without `.md`). This README is the only
> file using real relative paths, so it doubles as the name → path map. Legacy shop pages live
> under `legacy-shop/` and are linked as `[[legacy-shop/<name>]]`.

```
wiki/
  *.md                       app API + GraphQL domains + architecture + design (root)
  legacy-shop/*.md           Nuxt shop e-commerce (legacy, cookie session)
  missing-*.md               gap notes / resolved mapping
  flow-screen/*.png          Figma flow screenshots
  screens/
    onboarding/  screen-splash, screen-onboarding, screen-login, screen-survey
    app/         navigation, screen-home, screen-path, screen-diary, screen-benefits,
                 screen-statistics, screen-momenti, screen-notifications, screen-profile
```

## App API — REST (writes/actions)

- [overview](overview.md) — base URLs, the read/write split, surfaces
- [authentication](authentication.md) — Bearer JWT login/refresh/logout, content access
- [registration](registration.md) — register, password reset, newsletter
- [user-current](user-current.md) — `GET /users/me` (`myId`)
- [survey](survey.md) — onboarding status + submit
- [percorso](percorso.md) — step start/complete
- [strumenti](strumenti.md) — reminders + photo upload/delete
- [diario](diario.md) — goals/traguardi (`/journal/goals`)
- [profilo](profilo.md) — `PATCH /profile`
- [errors](errors.md) — error shapes & status codes

## App API — GraphQL (reads)

- [graphql](graphql.md) — endpoint, conventions, domain map
- [momenti](momenti.md) · [benefit-partner](benefit-partner.md) · [preferiti](preferiti.md)
  ([preferiti-apis](preferiti-apis.md)) · [notifiche](notifiche.md)
- [diario-attivita](diario-attivita.md) · [strumenti-read](strumenti-read.md)
- [percorso-read](percorso-read.md) · [integrazione](integrazione.md) ·
  [profilo-read](profilo-read.md)

## Client architecture

- [flutter-architecture](flutter-architecture.md) — BLoC, feature-first, Dio/Retrofit
- [auth-implementation-plan](auth-implementation-plan.md) — step-by-step plan to build login & registration
- [user-session-implementation-plan](user-session-implementation-plan.md) — fetch & cache the user after login (`/users/me` + `GetUserDetails`), profile_status routing

## Design & screens

Derived from Figma **KILOCAL-PROGRAM** (`figma.com/design/wvV8JURTECntVCsHl5sNLc`).

- [design-system](design-system.md)
- [navigation](screens/app/navigation.md)

### Onboarding flow

- [screen-splash](screens/onboarding/screen-splash.md) ·
  [screen-onboarding](screens/onboarding/screen-onboarding.md) ·
  [screen-login](screens/onboarding/screen-login.md) ·
  [screen-survey](screens/onboarding/screen-survey.md)

### Program app (in-shell)

- [screen-home](screens/app/screen-home.md) · [screen-path](screens/app/screen-path.md) ·
  [screen-diary](screens/app/screen-diary.md) · [screen-benefits](screens/app/screen-benefits.md) ·
  [screen-statistics](screens/app/screen-statistics.md) ·
  [screen-momenti](screens/app/screen-momenti.md) ·
  [screen-notifications](screens/app/screen-notifications.md) ·
  [screen-profile](screens/app/screen-profile.md)

## Legacy — shop e-commerce (reference only)

- [legacy-shop/overview](legacy-shop/overview.md) ·
  [legacy-shop/authentication](legacy-shop/authentication.md) ·
  [legacy-shop/settings](legacy-shop/settings.md) ·
  [legacy-shop/cart](legacy-shop/cart.md) ·
  [legacy-shop/cart-data-model](legacy-shop/cart-data-model.md) ·
  [legacy-shop/orders](legacy-shop/orders.md) ·
  [legacy-shop/paypal](legacy-shop/paypal.md) ·
  [legacy-shop/users](legacy-shop/users.md) ·
  [legacy-shop/user-addresses](legacy-shop/user-addresses.md) ·
  [legacy-shop/finder](legacy-shop/finder.md) ·
  [legacy-shop/cms-proxy](legacy-shop/cms-proxy.md) ·
  [legacy-shop/shop-apis-refresh](legacy-shop/shop-apis-refresh.md) ·
  [legacy-shop/contradictions-legacy](legacy-shop/contradictions-legacy.md)

## Contradictions & gaps

- [swagger](swagger.md) — live API docs URL, staging credentials, raw-spec fetch
- [contradictions](contradictions.md) — PDF (shop) vs Swagger (app), the big realignment
- [missing-apis](missing-apis.md) — proposals → real endpoints (resolved mapping)
- [missing-informations](missing-informations.md) — remaining gaps (Italian)
- [open-gaps-be-design](open-gaps-be-design.md) — **BE/design blockers** (Firebase push, stats period filter, biotype texts, profile image, onboarding copy, …)
