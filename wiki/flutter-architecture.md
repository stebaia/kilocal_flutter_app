# Flutter App Architecture

Architecture plan for the `kilocal_flutter_app` client.

> ⚠️ **Partly outdated — needs a feature-map refresh.** The decisions below (Clean
> Architecture, bloc/cubit, Retrofit/Dio, GoRouter, get_it) **still hold**. But the **feature
> list and endpoint table** describe the legacy **shop** (cart, checkout, paypal, cookie auth)
> — see `legacy-shop/`. The real app is **Directus + Bearer JWT**, hybrid **GraphQL reads +
> REST writes** ([[overview]]). The feature slices should be: `auth`, `survey`, `percorso`,
> `diario`, `strumenti`, `profilo`, `momenti`, `benefit`, `notifiche`, `integrazione` — each
> with a Dio-based GraphQL datasource for reads and a Retrofit REST client for writes. Treat
> the cart/checkout/paypal rows below as **legacy** until this page is rewritten.

## Decisions

| Concern | Choice | Rationale |
|---------|--------|-----------|
| State management | **bloc / cubit** (`flutter_bloc`) | **Bloc** for multi-event flows (auth, cart, checkout); **Cubit** for simple flows (settings, single-shot loads). |
| Project structure | **Clean Architecture**, feature-first | Each feature self-contained as `data / domain / presentation`. |
| Networking | **Retrofit** over **Dio** | Retrofit generates the typed API client; Dio provides interceptors (cookie + Bearer auth, error mapping, CORS-aligned headers). See [[authentication]]. |
| Serialization | **json_serializable** (codegen) | Typed models with generated `fromJson`/`toJson`. |
| Navigation | **GoRouter** | Declarative routing + deep links (mirrors `/finder` slugs — see [[finder]]). |
| DI | **get_it** + bloc providers | Wire datasources → repositories → blocs/cubits. |

## Layers (per feature)

```
presentation  →  domain  →  data
   (UI, Bloc)     (entities,   (DTOs, datasources,
                   repo ifaces)  repo impls, Dio)
```

- **data** — Retrofit API clients (Dio-backed), JSON DTOs, repository implementations.
- **domain** — pure entities, repository interfaces, (optional) use cases.
- **presentation** — Blocs/Cubits, screens, widgets.

Dependencies point inward only: presentation depends on domain; data implements domain. The
domain layer has no Flutter/Dio imports.

## Mandatory rules

These are non-negotiable conventions for all presentation-layer code:

- **Never use `setState`.** It is imperative; we manage state with **bloc / cubit**. Drive all
  UI state through a Bloc/Cubit and rebuild via `BlocBuilder` / `BlocConsumer` /
  `context.watch`. Widgets stay declarative — no `StatefulWidget` mutable state for app logic.
- **Every string must ALWAYS be translated.** No hardcoded user-facing text — all strings go
  through l10n (ARB files), referenced via the generated `AppLocalizations` (`context.l10n.*`).
  Default locale is Italian (`it`); English is the ARB template/fallback. See [[i18n]].

## Folder structure

```
lib/
  main.dart
  app/
    app.dart                 // MaterialApp.router
    router.dart              // GoRouter config
    di.dart                  // get_it registration
  core/
    network/
      dio_client.dart        // base Dio + interceptors (shared by all Retrofit clients)
      auth_interceptor.dart  // attaches Bearer; credentials: include
      cookie_store.dart      // klkl-data / klkl_refresh_token persistence
      api_exception.dart     // maps statusMessage codes → typed errors
      // each feature owns its Retrofit client in features/<f>/data/ (e.g. cart_api.dart)
    config/
      env.dart               // SHOP_URL, CMS_URL per flavor
    theme/                   // brand colors, gradient, ThemeData — see [[design-system]]
    widgets/                 // shared UI
  features/
    auth/        { data, domain, presentation }   // [[authentication]], [[users]]
    settings/    { data, domain, presentation }   // [[settings]]
    cart/        { data, domain, presentation }   // [[cart]], [[cart-data-model]]
    orders/      { data, domain, presentation }   // [[orders]]
    checkout/    { data, domain, presentation }   // [[paypal]]
    addresses/   { data, domain, presentation }   // [[user-addresses]]
    catalog/     { data, domain, presentation }   // products/kits via [[cms-proxy]] GraphQL
```

## Feature → API mapping

| Feature | Wiki page(s) | Key endpoints |
|---------|--------------|---------------|
| `auth` | [[authentication]], [[users]] | `/cms/auth/login`, `/logout`, `/api/users`, `/api/auth/password-*` |
| `settings` | [[settings]] | `GET /api/settings` |
| `cart` | [[cart]], [[cart-data-model]] | `/api/cart/init`, `items/upsert`, `items/delete`, `discounts/*`, `addresses/store` |
| `orders` | [[orders]] | `POST /api/orders/upsert` |
| `checkout` | [[paypal]] | `POST /api/paypal` |
| `addresses` | [[user-addresses]] | `/api/user-addresses[/{id}]` |
| `catalog` | [[cms-proxy]] | `POST /cms/graphql`, `GET /cms/items/{collection}`, `/cms/assets/{id}` |

## Networking concerns

- **Session**: persist `klkl-data` + `klkl_refresh_token` cookies (7-day, `SameSite=lax`,
  `Secure` in prod). All authenticated calls send credentials and `Authorization: Bearer`
  ([[authentication]]).
- **Token refresh**: on `401`, attempt `POST /cms/auth/refresh` once, then retry; otherwise emit
  an auth-expired state and route to login. Note PayPal returns its 401 message in Italian
  (see [[contradictions]] §4) — map by status code, not message text.
- **Error mapping**: centralize `statusMessage` → typed `ApiException`. Because casing/format is
  inconsistent across endpoints ([[contradictions]] §3), switch on **HTTP status + a normalized
  code**, never on the raw message string.
- **Cart auth nuance**: cart is publicly reachable but behaves differently when logged in
  ([[contradictions]] §1); the `cart` bloc must handle both anonymous and authenticated state and
  reconcile `storeCartUUID` on login.

## Bloc / Cubit inventory (initial)

`Bloc` = event-driven, multiple actions; `Cubit` = simple method-driven state.

| Bloc/Cubit | States (abridged) | Triggers |
|------|-------------------|----------|
| `AuthBloc` | unauthenticated / authenticating / authenticated / expired | login, logout, refresh |
| `CartBloc` | empty / loading / loaded(Cart) / error | init, addItem, removeItem, applyDiscount, storeAddresses |
| `OrderBloc` | idle / submitting / created(Order) / error | upsert |
| `CheckoutBloc` | idle / creating / paypalReady(links) / error | createPaypalOrder |
| `AddressBloc` | loaded(list) / mutating / error | create, update, delete |
| `SettingsCubit` | loading / loaded / error | fetch on startup |

## Recommended packages

```
flutter_bloc, bloc, equatable
dio, retrofit, pretty_dio_logger
retrofit_generator      (dev)
json_annotation        (+ json_serializable, build_runner dev)
get_it
go_router
flutter_secure_storage  (session cookies/tokens)
```

## Suggested build order

1. `core/network` (Dio, interceptors, error mapping) + `core/config`.
2. `auth` feature end-to-end (login/logout/refresh) — unblocks authenticated calls.
3. `cart` + `cart-data-model` (core shopping flow, anonymous → authenticated).
4. `catalog` (products/kits via GraphQL) to populate the cart.
5. `addresses` → `orders` → `checkout` (PayPal) to complete the purchase funnel.
6. `settings` cubit wired at app startup.

## Related

- [[README]]
- [[overview]]
- [[design-system]]
- [[screen-splash]]
- [[authentication]]
- [[cart]]
- [[contradictions]]
