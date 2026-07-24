# Open gaps — backend / design (not app-side)

Blockers that are **not** the Flutter app's fault: they need the **backend** to add an
endpoint/field, or the **design team** to define content/screens. Verified against the live
Swagger (see [[swagger]]) on **2026-07-07**. Each item says what exists today and the exact
question for the team.

> These are BE/graphic gaps, distinct from the resolved app-API mapping in [[missing-apis]].
> Where a gap already has its own note, this page links to it and stays the single index.

---

## 1. Firebase integration missing on the backend

- **State:** the app has Firebase (Crashlytics/Analytics/Performance/FCM) wired **client-side**
  ([[monitoring-analytics-status]] in memory), but the **backend does not send push**. The app
  Swagger states literally: `job_channel: web_app` — *"push FCM/APNs non implementato"*
  ([[notifiche]]). No device-token / push-registration endpoint exists in either the app spec
  or the Directus OAS (checked `firebase|fcm|device_token|apns` → **0 hits**).
- **Missing (BE):**
  1. An endpoint to **register the FCM/APNs device token** for the logged-in user
     (e.g. `POST /profile/push-token` or a `user_devices` collection).
  2. A **job/campaign channel** that actually delivers to FCM/APNs (today only `web_app`).
- **Question for the team:** will push be delivered via Firebase, and which endpoint does the
  app call to register its token? Until then, notifications are in-app only ([[notifiche]]).

## 2. Statistics — no monthly / period filter

- **State:** the only progress endpoint is **`GET /path/me/progress`** ([[percorso-read]]),
  which returns a **lifetime** aggregate: `overall` + the 4 areas, each just
  `{ completed, total, percent }` (schema `PercorsoProgress` / `PercorsoProgressCount`).
  There is **no `month`, `period`, `timeframe`, or date-range parameter**.
- **What the design wants:** `statistiche.png` shows *"Statistiche **mese corrente**"* with an
  `x/y attività` count per area and a calendar icon (implying a period selector).
- **Missing (BE):** either a `?month=` / `?timeframe=` query on `/path/me/progress`, **or** a
  documented GraphQL aggregation of `user_activities` grouped by month (`user_activities_aggregated`
  with `groupBy: ["month(completed_on)"]` is mentioned in the spec but not exposed as the
  statistics contract).
- **Question for the team:** how do we filter statistics by period? Add a param to
  `/path/me/progress`, or confirm the client should aggregate `user_activities` itself?
  See [[screen-statistics]] and [[statistics-feature-status]] (memory: current-month v1 is
  unblocked; the timeframe selector is not).

## 3. Benessere — how to follow the steps

- **State:** already tracked. Benessere detail = 3 cards (Mindfullness / Self Care / Stili di
  vita) from `/steps` groups, all `is_percorso_main_tab=false` — so they are **not** the main
  step-based tab and the usual start/complete flow doesn't map cleanly (memory:
  [[benessere-subsections]]).
- **Missing (design/BE):** confirmation of what "completing" a benessere step means and which
  group drives progress, since `/path/me/progress` counts only the main-tab group.
- **Question for the team:** which benessere group is the "followable" one, and do its steps use
  `POST /path/steps/{id}/start|complete` like the other areas?

## 4. Integrazione — images don't add up

- **State:** integration is phase-based, not step-based ([[integrazione]]). `kit_products →
  products_with_duration → product { asset { id } }` gives a product asset, and
  `product_phases` has translations, but the Figma detail (Kilocal SlimCell) shows richer
  imagery (hero, instruction images) that don't clearly map to a single `asset`.
- **Missing (BE/design):** a defined image field per phase/product for the detail screen
  (hero vs thumbnail vs instruction images), and the resolution/format to request from
  `/assets/{id}`.
- **Question for the team:** which asset field feeds the integration **detail** header and the
  per-product images? Today only `product.asset { id }` is confirmed.

## 5. Profilo — biotype texts

- **State:** biotype ("Il mio Tipo" / silhouette) reads from `profiles` /
  `profiles_translations` (`content`, `content_f`) — verified schema, but those collections are
  **auth-role gated** and the texts are long editorial content (memory:
  [[profiles-biotype-schema]], [[profile-cms-pages-schema]]).
- **Why not hardcode:** the 7 biotype descriptions are CMS-managed editorial copy per
  gender — hardcoding them in the app would fork them from the CMS and break i18n.
- **Missing (BE):** confirm the app role can **read** `profiles_translations` (or expose the
  biotype text through a REST profile read), so the texts come from the CMS, not the binary.
- **Question for the team:** can the mobile role query `profiles` / `profiles_translations`, or
  should biotype text ship via a dedicated read endpoint? See [[profilo-read]], [[screen-profile]].

## 6. Profilo — screens with no Figma / no API

Several profile menu items appear in the app but have **no Figma design** and **no documented
endpoint**. They are either static CMS content or native OS actions:

| Voice | Nature | What's needed |
|-------|--------|---------------|
| **Tutorial "come usare l'app"** | onboarding content | design + content source (CMS page? reuse [[screen-onboarding]] slides?) |
| **Contatta l'assistenza** | support | design + channel — mailto? in-app form? which address/endpoint? |
| **Valuta l'app** | native | store review prompt (`in_app_review`) — no API, but confirm store IDs |
| **Informativa sulla privacy** | legal | URL or CMS page? (Directus has `private_pages`, memory [[profile-cms-pages-schema]]) |
| **Termini di servizio** | legal | URL or CMS page? same as privacy |
| **Cambia immagine profilo** | avatar upload | **which API?** — see §7 |

- **Missing (design):** Figma for Tutorial, Contatta assistenza; and the exact target for
  Privacy / Termini (external URL vs CMS `private_pages`).
- **Question for the team:** are Privacy/Termini fixed URLs or CMS pages, and where does
  "Contatta l'assistenza" send the request?

## 7. Profilo — "Cambia immagine profilo": which API?

- **State:** the app `PATCH /profile` write ([[profilo]]) has **no avatar field**, and there is
  **no dedicated profile-image endpoint** in the app spec. Only the generic Directus layer
  exists: `POST /files` (upload → file UUID) and `directus_users.avatar` (relation on the user).
- **Missing (BE):** a confirmed path for the app: upload via `/files` then set
  `user_details`/`directus_users.avatar`? Or extend `PATCH /profile` with an avatar field?
- **Question for the team:** what is the supported flow to set the profile picture — generic
  `/files` + avatar relation, or a new profile field? Confirm before wiring.

## 9. Home "continue path" card — step cover images missing in the CMS

- **State:** verified live on staging (2026-07-24) with the `mobile.test.active@thefullproject.it`
  test account. `user_details.percorso_allenamento_curr_step` **does** advance correctly after
  completing a step (confirmed: after finishing "settimana 1 - allenamento 1", `curr_step` moved
  to id 12 / sort 7 / "settimana 3 - allenamento 2"), so the home hero card's "next content"
  pointer is not the problem.
- **The actual gap:** the preview image never changes because almost no `percorsi_content` row has
  a cover image. Introspection + a full scan of `percorsi_content` (157 rows) on staging show:
  **156/157 are video content** (`asset.asset_is_video: true`, with a `vimeo_url`), and only
  **1/157** has ever had `asset.default_asset` or `asset.mobile_asset` populated — the two fields
  the home query (`HomeContinueAndText` in `home_repository_impl.dart`) reads for the thumbnail.
  With those null, the app correctly falls back to the local placeholder
  (`assets/training.png`), which is why the image looks "stuck" regardless of which step is
  current.
- **Missing (content/CMS):** cover images (`default_asset`/`mobile_asset`) uploaded on the
  `assets` junction row for each video step — or a decision to source the thumbnail elsewhere
  (e.g. a Vimeo oEmbed thumbnail, which the app already fetches for playback via
  `vimeo_oembed_service.dart`, as a fallback when `default_asset`/`mobile_asset` are null).
- **Question for the team:** will the content team backfill cover images for the ~156 video
  steps, or should the app derive the preview thumbnail from Vimeo's oEmbed response instead?

## 10. Onboarding — which texts?

- **State:** `splash.png` frame is *"SPLASH + APPRODO SALES SPEECH"* with an N-step carousel,
  but the copy is placeholder ("Lorem Ipsum") — no final text and no content endpoint
  ([[screen-onboarding]], [[missing-informations]] §5).
- **Missing (design/BE):** the actual onboarding slide copy (titles + bodies + CTA labels), and
  whether it's **static in the app** or served from the CMS (no onboarding collection is exposed
  in the OAS).
- **Question for the team:** provide the final onboarding texts, and say whether they are fixed
  in the build or CMS-driven.

---

## Summary — what to ask the backend / design

| # | Gap | Owner | Ask |
|---|-----|-------|-----|
| 1 | Firebase push | BE | device-token registration endpoint + FCM/APNs delivery channel |
| 2 | Statistics period filter | BE | `?month=`/timeframe on `/path/me/progress` or confirm client aggregation |
| 3 | Benessere steps | BE/design | which group is followable; does it use `/path/steps/*`? |
| 4 | Integrazione images | BE/design | which asset field feeds detail header / product images |
| 5 | Biotype texts | BE | can mobile role read `profiles_translations`? |
| 6 | Profile extra screens | design | Figma + target for Tutorial/Support/Privacy/Termini |
| 7 | Profile image | BE | supported avatar-upload flow (`/files`+avatar vs new field) |
| 9 | Home continue-path cover images | content/CMS | backfill `default_asset`/`mobile_asset` on video steps, or use Vimeo oEmbed thumbnail |
| 10 | Onboarding texts | design | final slide copy; static vs CMS |

## Related

- [[swagger]] · [[missing-apis]] · [[missing-informations]]
- [[notifiche]] · [[percorso-read]] · [[integrazione]] · [[profilo-read]] · [[profilo]]
- [[screen-statistics]] · [[screen-profile]] · [[screen-onboarding]]
