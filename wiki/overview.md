# Overview — mobile app API

The Kilocal **mobile app** (iOS/Android) talks **directly to the Directus CMS**. Source of
truth: Swagger **`/api/docs`** → tab *Kilocal App* (`/api/docs/openapi.yaml`, spec v1.2.1).

> The old [[legacy-shop/overview|shop e-commerce]] (Nuxt, cookie session) is a **different
> system** — see `wiki/legacy-shop/` and [[contradictions]].

## Base URL

| Env | URL |
|-----|-----|
| Staging | `https://cms-stg.kilocal.thefullproject.it` |
| Production | `https://cms.kilocalprogram.it` |
| Local (Docker) | `http://localhost:8055` |

Auth: **Bearer JWT** (`/auth/login` → `Authorization: Bearer …`). See [[authentication]].

## The hybrid model (read vs write)

The backend deliberately splits responsibilities — the app uses **both**:

| | Layer | What |
|-|-------|------|
| **Read** content | **GraphQL** `POST /graphql` | percorsi, momenti, benefit, notifiche, glossario, foto, profilo, diario-attività, integrazione |
| **Write** / actions | **REST** extensions | login, registrazione, complete step, promemoria, traguardi, upload foto, profilo, survey |

Why: Directus exposes native GraphQL for reading any collection (filters, sort, paging) with
no hand-written endpoints; writes with business logic (e.g. completing a step touches 3
collections + advances the timeframe) sit behind custom REST extensions (`path`, `tools`,
`journal`, `survey`, `profile`). A given datum is usually read via GraphQL **or** written via
REST — rarely both. Exceptions: [[preferiti]] and [[notifiche]] also write via GraphQL
mutation (simple toggles, no logic).

> **Flutter client:** GraphQL reads are raw `POST /graphql` via **Dio** (same client as REST),
> no dedicated GraphQL package.

## REST surface (writes/actions)

| Area | Routes | Page |
|------|--------|------|
| Auth | `/auth/login`, `/auth/refresh`, `/auth/logout` | [[authentication]] |
| Registration | `/api/auth/register`, `/api/auth/password-*`, `/api/newsletter/subscribe` | [[registration]] |
| Current user | `GET /users/me` | [[user-current]] |
| Survey | `/survey/me/*`, `/survey/submit/{internalName}` | [[survey]] |
| Percorso | `/path/steps/{stepId}/start|complete` | [[percorso]] |
| Strumenti | `/tools/reminders*`, `/tools/photo-gallery` | [[strumenti]] |
| Diario | `/journal/goals*` | [[diario]] |
| Profilo | `PATCH /profile` | [[profilo]] |

## GraphQL surface (reads)

Overview + per-domain pages: [[graphql]] → [[momenti]], [[benefit-partner]], [[preferiti]],
[[notifiche]], [[diario-attivita]], [[strumenti-read]], [[percorso-read]], [[integrazione]],
[[profilo-read]].

## Response format

JSON. Directus convention: `{ "data": … }` on success; errors via `errors[]`
(GraphQL returns `200` even on logical errors). See [[errors]].

## Content access

Endpoint auth ≠ content access. Visible hubs/tools are driven by `user_details.profile_status`
and server-side CMS filters (profile type + gender). See [[authentication]].

## Related

- [[authentication]]
- [[graphql]]
- [[contradictions]]
- [[missing-apis]]
- [[README]]
