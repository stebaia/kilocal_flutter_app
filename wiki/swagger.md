# Swagger — live API docs

Single source of truth for the Kilocal **app** API. Two specs live behind the same URL:

| Spec | URL | What it is |
|------|-----|-----------|
| **Kilocal App** (use this) | `https://cms-stg.kilocal.thefullproject.it/api/docs` → tab *Kilocal App* | hand-written REST contract for the mobile app (`/auth`, `/survey`, `/path`, `/tools`, `/journal`, `/profile`, `/graphql`). Raw spec: `/api/docs/openapi.yaml` |
| **Directus (auto)** | same `/api/docs`, default tab | auto-generated OAS for every Directus collection/endpoint (`/items/*`, `/files`, `/assets/{id}`, …). Raw spec: `/server/specs/oas` (JSON) |

## Access

- **Environment:** staging — `https://cms-stg.kilocal.thefullproject.it`
- **Basic auth (staging gate):** `mariorossi@fakemail.com` / `PA^5Vae9QBQyM@r`
- The API itself uses **Bearer JWT** ([[authentication]]); the basic-auth above only unlocks the
  staging host / Swagger UI.

## Fetching the raw specs

```bash
# App spec (the important one)
curl -u 'mariorossi@fakemail.com:PA^5Vae9QBQyM@r' \
  https://cms-stg.kilocal.thefullproject.it/api/docs/openapi.yaml

# Directus auto-generated OAS (all collections)
curl -u 'mariorossi@fakemail.com:PA^5Vae9QBQyM@r' \
  https://cms-stg.kilocal.thefullproject.it/server/specs/oas
```

A snapshot of the app spec is saved at `raw/swagger/kilocal-app-openapi.yaml` (refreshed
2026-07-07 — added `GET /path/me/progress` and `GET /path/me/areas/{area}/steps`).

## Related

- [[overview]] · [[graphql]] · [[open-gaps-be-design]] · [[missing-apis]]
