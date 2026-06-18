# Contradictions & inconsistencies

We now have **two sources** that describe **two different systems**:

1. `raw/KILOCAL DOCUMENTAZIONE TECNICA.pdf` (v1.0) — the **Nuxt shop e-commerce**
   (`kilocal-shop-fe`). → `wiki/legacy-shop/`.
2. Swagger **`/api/docs`** → tab *Kilocal App* (`/api/docs/openapi.yaml`, v1.2.1) — the
   **mobile app** against Directus. → the rest of this wiki.

The mobile-app Swagger is now the **source of truth** for the app. The PDF is legacy.

## 1. PDF (shop) vs Swagger (app) — the big one

| Aspect | PDF / shop (legacy) | Swagger / app (authoritative) |
|--------|---------------------|-------------------------------|
| Base URL | `{SHOP_URL}/api/*`, `{SHOP_URL}/cms/*` | `https://cms-stg.kilocal.thefullproject.it` (Directus direct) |
| Auth | **cookie session** (`klkl-data`, `klkl_refresh_token`) | **Bearer JWT** (`/auth/login` + `/auth/refresh`) |
| Login path | `POST {SHOP_URL}/cms/auth/login` | `POST /auth/login` with `mode: json` |
| Cart / orders / paypal / settings | present | **absent** — not part of the app |
| Reads | REST `/api/*` + GraphQL via proxy | **GraphQL `POST /graphql`** (direct) |
| Reminders / photos / profile | proposed `/api/*` (missing) | real `/tools/*`, `/profile`, `/journal/*` |

→ Do not mix the two. App work uses the Swagger; shop pages are kept only for reference.

## 2. `missing-apis.md` proposals are now mostly real

[[missing-apis]] listed ~30 "endpoint proposti da confermare". Most now **exist**, at
**different paths**. See that page for the full mapping. Examples: survey →
`/survey/submit/{internalName}`; percorso → `/path/steps/{stepId}/start|complete`; reminders →
`/tools/reminders`; photos → `/tools/photo-gallery`; profilo → `PATCH /profile`; diario →
`/journal/goals`; momenti/benefit/notifiche/glossario → GraphQL.

## 3. Content-access model — now answered

[[missing-apis]] §2bis asked how locked hubs/tools work. The Swagger answers:
`user_details.profile_status` (`active`, `active_restricted_access`, …) + server-side CMS
filters (profile type + gender) + `is_tool_blocked`. See [[authentication]].

## 4. Two route prefixes in the app spec

Auth is split: native Directus `/auth/*` (login/refresh/logout) vs Kilocal extension
`/api/auth/*` (register/password). Not a contradiction, but easy to get wrong — always send
`origin: app` on the `/api/auth/*` ones. See [[authentication]] / [[registration]].

## 5. Some GraphQL collections absent from the public SDL

`moments`, `percorsi`, `percorsi_groups`, `percorsi_content`, `timer` are **not** in
`/server/specs/graphql/items` (public role). They require an authenticated role; the Swagger
documents them anyway. Field lists for those come from the Swagger, not the SDL.

## 6. Push notifications not implemented

[[notifiche]]: `job_channel: web_app` only — no FCM/APNs. The app inbox is poll/read, not push.
A Figma that implies push would be unsupported today.

## Internal inconsistencies (legacy shop)

The PDF's own internal inconsistencies (cart "Public" framing, duplicate `Cart not found`,
mixed error-message style, Italian-vs-English errors, settings without status code) are kept in
[[legacy-shop/contradictions-legacy]] for the record.

## Related

- [[README]]
- [[overview]]
- [[authentication]]
- [[missing-apis]]
- [[graphql]]
