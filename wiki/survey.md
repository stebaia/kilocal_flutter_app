# Survey & onboarding

`survey` extension. Drives onboarding and the user profile (`user_details`). Bearer token
required; send `X-Kilocal-Origin: app`. Source: Swagger *Kilocal App*.

## Endpoints

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/survey/me/status` | onboarding state + completed surveys |
| GET | `/survey/me/month-end-status` | integrazione phase stats + pending month-end survey — **creates the Kilocal goal as a side-effect**, see [[diario]] |
| POST | `/survey/me/ensure-details` | create the `user_details` row if missing |
| POST | `/survey/submit/{internalName}` | submit survey answers |

### `GET /survey/me/status` → `SurveyMeStatus`

```json
{
  "data": {
    "profile_status": "initial_survey",
    "completed_surveys": ["type_survey"],
    "user_details_id": "…"
  }
}
```

`profile_status` values: `initial_survey`, `type_survey`, `starter_kit`, `active`,
`active_restricted_access`, `qr_pharmacy_1`, `qr_pharmacy_2`. See [[authentication]] for how
this gates content. `401` / `403` on missing token / wrong role.

### `POST /survey/me/ensure-details`

Idempotent — returns the `user_details` row, creating it if absent. Call early in onboarding.

### `POST /survey/submit/{internalName}`

`internalName` = the survey's internal name in the CMS (e.g. `type_survey`). Body
(`SurveySubmitBody`):

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `bmi` | number \| string | ✓ | computed client-side |
| `steps` | object | ✓ | map of `stepKey → SurveyStep` |
| `ageValue` | int \| null | — | |
| `pharmacy_data` | any \| null | — | QR pharmacy flow |
| `single_product_id` | string \| null | — | |

`SurveyStep`: `{ sectionId, storeToField?, answer }` where `answer` is a
`SurveyStepAnswer` (`{ id, value_to_store?, is_other?, other_value? }`), an array of them,
or a scalar (string/number/boolean).

Response (`SurveySubmitResponse`):

```json
{
  "data": {
    "survey_submit_id": "…",
    "profile_status": "starter_kit",
    "outcome": { },
    "kit_shop_url": "https://…",
    "legacy": { }
  }
}
```

`kit_shop_url` → suggested kit checkout (the recommended kit/biotype outcome). `legacy` is
web-client migration compatibility — ignore in the app.

### `outcome.profile` — result screen data (CONFIRMED, live 2026-07-16)

The `outcome` is **`{id, majority_of_values, profile}`**, and `profile` is only a
**reference** — it carries no copy:

```json
"outcome": { "id": 2, "majority_of_values": "2",
             "profile": { "id": 4, "kit_slug": "kit-tipo-2" } }
```

So the result screen's texts and images **must be hydrated** from the `profiles` collection
(`SurveyRepository.fetchOutcomeProfile` → `mapOutcomeProfile`), keyed by `profile.id`:

```graphql
profiles(filter: { id: { _eq: $id } }, limit: 1) {
  id
  icon { id }                            # SVG → CmsSvgIcon, not Image.network
  kit { asset { default_asset { id } } } # the real file; `asset` is only the wrapper
  translations(filter: { languages_code: { code: { _eq: $lang } } }) {
    title      # "Tipo 2"  → the display label
    name       # "Mela"    → the denomination
    content content_f      # gender-specific copy
  }
}
```

`{{type}}` = `"$title - $name"` ("Tipo 2 - Mela"); `content_f` is used for female profiles
(via `genderIsFemale`), with the gender read from the survey's own `is_gender_question`
answer rather than `user_details` — the submit has only just written it.

> ⚠️ The same submit response *also* carries the fully expanded profile under
> **`legacy.create_survey_submits_item.outcome.profile`** (translations, icon, kit, colors).
> **Do not read it**: `legacy` is documented in the OpenAPI spec as "compatibilità client web
> in migrazione" and will be removed. Hydrate from `profiles` instead.

The result section (CMS id 9, `type_survey`) templates its copy with **`{{name}}`, `{{type}}`
and `{{outcome_profile}}`** — names that match neither the response's keys nor each other, so
they are mapped explicitly in `_outcomePlaceholders` (`survey_screen.dart`). `{{name}}` comes
from the logged-in `AppUser.firstName`, not the outcome.

A failed hydrate is swallowed: the submit already succeeded server-side, so the screen shows
the survey's own copy rather than failing.

## Onboarding gate — proof of purchase is mandatory

`user_details.profile_status` **is** the gate; the app must not invent its own. Submitting
`type_survey` moves the status to `starter_kit`, and that survey opens (sort 1, section id
11) with **"Inserisci il codice a barre"** — a `required: true` input — and only ends with
"Hai completato il profilo!". So a user cannot reach the app without a proof of purchase,
provided the app honours the status.

> ⚠️ **The result screen must not offer a proof-of-purchase button.** It looks like it
> belongs (the web design shows one) but it is wrong twice over: it sits beside "Fine",
> reading as mandatory while being optional — press "Fine" and the survey simply ends — and
> it opens the restricted-access unlock sheet, whose `PATCH /profile → active` would skip the
> `starter_kit` survey entirely. The proof of purchase is collected **by that survey**
> (section 11, the only one flagged `show_single_product_cta`), which `profile_status` routes
> the user to next. Removed 2026-07-16 after it let a user press "Fine" and enter the app.

> The result screen's own CTA (last step of `type_survey`) now reads **"Continua"**, not
> "Fine" — `type_survey` always chains into `starter_kit` next (see the redirect below), so
> "Fine" was misleading. `_ctaLabel`'s fallback (`survey_screen.dart`) applies this to the
> last step of *every* survey, since any of them can be chained by `profile_status`.

### `show_single_product_cta` — "Non ho uno Starter Kit" (added 2026-07-20)

Section 11's `small_notification_text` tells a user without a Starter Kit to tap **"Non ho
uno Starter Kit"** to proceed via a single-product purchase instead. The button (rendered
whenever `section.showSingleProductCta` is true — currently only section 11/`starter_kit` and
mirrored by section 79/`single_product_survey`, which does not re-show it) navigates to
`/survey?internalName=single_product_survey`: a parallel flow that asks *which* product was
bought (a `show_as_dropdown` question) before its own barcode step. Both surveys' barcode
title templates `{{product}}` in quotes; see below.

### `{{product}}` placeholder (fixed 2026-07-20, kit source fixed 2026-07-28)

Both `starter_kit` (section 11) and `single_product_survey` (section 79) title their barcode
step `Inserisci il codice a barre di: "{{product}}"`, but neither survey's copy carried a
`product` key, so the placeholder rendered empty. `_SectionBody._productName`
(`survey_screen.dart`) resolves it:

- `single_product_survey` asks a `show_as_dropdown` product question (section 78) immediately
  before the barcode step — `{{product}}` is that question's selected option's label (e.g.
  "Kilocal AGE Menopausa").
- `starter_kit` has no such question. **Correct rule (confirmed by backend, 2026-07-28):** when
  the barcode section has `single_product_barcode_check == false`, the product is picked at
  **random from the user's own kit** (`user_details.profile.kit.id`), not a hardcoded name — a
  first pass literally used `"Starter Kit Kilocal"` for every user, which was wrong.
  `single_product_barcode_check == true` (other flows, e.g. the restricted-access unlock)
  keeps checking the generic `use_for_barcode_check` catalogue instead.

**Query** (`SurveyRepositoryImpl.fetchKitBarcodeProducts`, same shape as
`ProfileKitRepositoryImpl`): `product_kits_by_id(id: $kitId) { phases { products_with_duration {
kit_products_duration_id { product { id title barcodes variants { barcodes } } } } } }`,
flattened across phases (dedup by product id, no `show_in_shop` filter — this is for barcode
matching, not the shop listing). `SurveyCubit._loadKitBarcodeProduct` runs this once, unawaited,
right after `start()` loads the survey (only when a visible section needs it), shuffles the
eligible products (non-empty `codes`), and caches the pick in `SurveyState.kitBarcodeProduct`
(`{title, codes}`) for the rest of the wizard — both the `{{product}}` placeholder and this
step's barcode validation (`_isKnownBarcode`) read from that cache; a read failure leaves it
`null`, which fails the step closed (no code can match) and falls back to the literal
"Starter Kit Kilocal" for the placeholder text only.

⚠️ **`exclude_from_kit_barcode_check` does not exist in the CMS.** The initial spec described
filtering the kit's products by this field before picking one at random. Checked via GraphQL
introspection live on staging across every relevant collection (`products`, `kit_products`,
`kit_products_duration`, `product_variants`, `product_kits`) — no such field anywhere, only
`single_product_barcode_check` (on `survey_sections`) and `use_for_barcode_check` (on
`products`, a different flow). Backend confirmed (2026-07-28): the field exists on the web
front-end only, not in Directus — **skip that filter and consider every product in the kit
eligible.**

### `{{name}}` outside result screens (fixed 2026-07-28)

`starter_kit` section 6 (sort 2, an `info` section — no `possible_answer`, `use_custom_cta:
false`) titles itself `"{{name}} sei all'inizio del tuo percorso!"`. `{{name}}` was previously
only added to the placeholder map for `SurveySectionKind.result` sections (the `type_survey`
outcome screen), so it rendered empty here. `_SectionBody.build` now resolves `{{name}}` from
the logged-in user's `firstName` for **every** section, not just results; `_outcomePlaceholders`
only adds `{{type}}`/`{{outcome_profile}}` on top for result screens.

### `{{final_asset}}` — the "Hai completato il profilo!" screen (fixed 2026-07-21)

Both `starter_kit` (section 10, sort 17) and `single_product_survey` (section 93, sort 18)
end with `content: "<p>{{final_asset}}</p>"`. There is **no image field on `survey_sections`**
(verified via GraphQL introspection — `translations` only carries `title`/`subtitle`/
`content`, all `String`), so this isn't a CMS file attached to the section itself.

The image is a **local celebration illustration** (`assets/goal.png`, a clapping-hands 3D
render), the same asset already used for the Traguardi tab's hero card
(`DiaryHeroCard`/`diary_screen.dart`) — not backend data at all. `_FinalAssetImage`
(`survey_screen.dart`) renders it on the same red-gradient-card-with-white-circle framing as
`DiaryHeroCard`. First attempt (since reverted) wrongly assumed this had to come from the
user's biotype kit image (`user_details.profile.kit`) — it doesn't; the placeholder is filled
locally, no fetch involved.

Two things enforce it:

1. **`appRouter.redirect`** (`onboardingRedirectFor`, `lib/app/router.dart`) — while
   `profileStatus.surveyInternalName != null`, any navigation is redirected onto that survey.
   Exempt: the auth routes (no session to gate — redirecting would bounce the user off
   `/login`) and `/survey` itself. Only applies once `UserStatus.loaded`.
2. **The survey's own exit** — on completion the screen reloads the session and follows
   `UserState.route` instead of hardcoding `/home`, so finishing `type_survey` chains
   straight into `starter_kit`.

> The `/survey` route is keyed by `internalName` (`ValueKey('survey-$internalName')`):
> chaining one survey onto another keeps the same path, so without the key GoRouter reuses
> the Element and the finished survey stays on screen.

### `other_validations` — enforced (2026-07-16)

`survey_question.other_validations` is a `|`-separated rule list. The CMS only uses six
(enumerated live across every question):

| Rule | Question | Enforced by |
|------|----------|-------------|
| `number\|int\|gte:100\|lte:300` | height (cm) | `SurveyValidationRule` |
| `number\|lte:300\|gte:30\|bmi:17.5` | weight (kg) | `SurveyValidationRule` |
| `date\|max:{-18years}\|min:1900-01-01` | date of birth | `SurveyValidationRule` |
| `zip_code` | CAP (5 digits) | `SurveyValidationRule` |
| `phone` | phone | `SurveyValidationRule` |
| `barcode` | starter kit proof of purchase | products catalogue (async) |

Sync rules run as the user types (`SurveyState.currentValidationError`) and disable the CTA
with the reason shown in the footer. Unknown tokens are ignored on purpose — a rule the app
cannot interpret must never block the user.

**`bmi:17.5`** needs the height answered earlier in the same survey (located by
`user_data_field_name == 'height'`, as `buildSubmitBody` does). Without it the BMI bound is
skipped rather than guessed.

**`barcode` is not a format check.** It means "matches a code in `products` where
`use_for_barcode_check = true`" — the same rule the restricted-access unlock sheet applies,
so `SurveyCubit` reuses `ProgramUnlockRepository.fetchBarcodeProducts()` rather than
duplicating the query. It is checked when the CTA is pressed (it needs the network), and a
catalogue read failure **does not** let the user through: failing open would defeat the gate.

> `SurveyState.canLeaveCurrentStep` is the single source of truth for both the CTA's enabled
> state and the cubit's own guard in `next()`, so the button cannot promise something the
> cubit will refuse.

> ⚠️ `SurveyState.copyWith(errorMessage: null)` **cannot clear the error** — a null argument
> is indistinguishable from "not passed". Use `clearError: true`.

> ⚠️ The disclaimer ("Attenzione: le informazioni e i consigli…") appears **twice** on the
> result screen: once hardcoded in the CMS `content` field after `{{outcome_profile}}`, and
> once inside the profile copy itself. Backend said the duplicate is being removed on their
> side ("è a post"); the app renders whatever the CMS returns.

**Open question:** "Trova una Farmacia Kilocal Point" (present in the web survey result) has
no destination in the app contract — no URL in the CMS response, and the `pharmacies`
collection has no public finder page. The button is hidden until backend supplies one; see
`SurveyResultActions.pharmacyFinderUrl`. Re-checked live via GraphQL introspection
(2026-07-20): `pharmacies` still has no finder-page field and `surveys` has no URL field —
still blocked, nothing to wire yet.

> **Survey questions** (sections, options, conditions) are **read** via [[graphql]] on the
> `surveys` / `survey_sections` / `survey_question` collections — there is no dedicated REST
> GET. This resolves the proposed `GET /api/survey/{type}` in [[missing-apis]] §1.

### Risky-selection gating (`#stop#` / `#alert#`)

An option's `result_value` (normally a biotype score, see below) can instead carry one of two
markers, generic to **any** option on **any** question — not specific to a "gravidanza"
flag on the section:

| Marker | Behavior |
|--------|----------|
| `#stop#` | Selecting it and pressing the CTA blocks the survey outright: the wizard jumps straight to the survey's **last section** and renders its own `title`/`subtitle`/`content` (already CMS copy, no new fields needed) instead of that section's normal result/question body. No submit happens. The user can still go back (arrow) to change the answer, which un-pins the block. |
| `#alert#` | Pressing the CTA shows a confirmation dialog (title/content) instead of advancing. Confirming lets the user continue; dismissing keeps them on the step. |

Implemented in `SurveyOption.resultAction` (`survey_step.dart`), `SurveyState.currentResultAction`
/ `blockedByStop` / `pendingAlert` (`survey_state.dart`), and the interception in
`SurveyCubit.next()` (`survey_cubit.dart`).

**Open question:** the `#alert#` dialog copy is CMS-driven
(`alert_survey_risky_selection_modal`), but there is no confirmed collection/schema for it —
unlike every other CMS read in this file, nothing here was verified against a live GraphQL
introspection. `SurveyRepositoryImpl.fetchAlertModal()` guesses a `survey_alerts` collection
filtered by `internal_name`, mirroring the `private_pages` pattern
(`profile_page_repository_impl.dart`); a missing/failed read degrades to letting the user
through unblocked rather than trapping them on a dialog with no copy. **Needs backend
confirmation** of the real collection/field names before this can be trusted live.

## Read model (GraphQL) — verified on staging

The survey definitions are readable on `POST /graphql` (staging returns them **even
without a token**; production likely bearer-gated). Verified 2026-07-02 against
`cms-stg`. Five surveys exist:

| `internal_name` | Role |
|-----------------|------|
| `type_survey` | Initial survey → biotype/kit result ("sei un Tipo N") |
| `starter_kit` | Post-purchase final survey (barcode → intro platform) |
| `qr_pharmacy_1` / `qr_pharmacy_2` | Pharmacy QR onboarding (+ `load_kilocal_points` step) |
| `single_product_survey` | Single-product purchase (product dropdown + barcode) |

### Query shape

```graphql
query GetSurvey($internalName: String!, $lang: String!) {
  surveys(filter: { internal_name: { _eq: $internalName } }, limit: 1) {
    id
    internal_name
    possible_outcomes          # String (nullable) — outcome scoring config
    sections(sort: ["sort"]) {
      sort
      survey_sections_id {
        id
        condition_action       # "show" | "hide"
        use_custom_cta         # result/intro screens use a custom CTA
        store_in_user_data     # persist the answer to user_details
        user_data_field_name   # e.g. date_of_birth, gender, height, weight, menopause
        load_kilocal_points    # pharmacy step
        show_single_product_cta
        single_product_barcode_check
        show_as_dropdown       # render options as a dropdown (single_product_survey)
        small_notification_text
        is_dob_question is_gender_question is_menopausa_question
        translations(filter: { languages_code: { code: { _eq: $lang } } }) {
          title subtitle content   # HTML — strip/render
        }
        default_cta_translations(filter: { languages_code: { code: { _eq: $lang } } }) {
          label                # "Avanti" | "Inizia" | "Continua" | "Chiudi"
        }
        conditions(sort: ["sort"]) {
          survey_section_conditions_id {   # NULLABLE (dangling junctions exist — guard)
            condition          # Directus op, e.g. "_eq"
            simple_value
            value { id }       # a survey_question_options id
            values { survey_question_options_id { id } }
          }
        }
        possible_answer {      # NULL for info/intermezzo/result sections
          id
          type                 # "radio" | "checkbox" | "input" | "scale"
          input_type           # "text" | "number" | "date"
          required
          scale_values         # JSON, e.g. [{ "from": 0, "to": 10 }]
          result_value
          other_validations    # Zod-style, e.g. "number|int|gte:100|lte:300"
          text_translations(filter: { languages_code: { code: { _eq: $lang } } }) {
            placeholder
          }
          scale_translations(filter: { languages_code: { code: { _eq: $lang } } }) {
            initial_label final_label
          }
          options(sort: ["sort"]) {
            survey_question_options_id {
              id sort
              is_other          # true → show a free-text field when selected
              result_value      # score for this option
              value_to_store    # value persisted (e.g. gender m/f/other)
              deselect_others   # true → selecting clears the other checkboxes ("Nessuno")
              translations(filter: { languages_code: { code: { _eq: $lang } } }) {
                text warning_when_selected
              }
            }
          }
        }
      }
    }
  }
}
```

### Section → screen-type mapping (from the wireframes)

| Wireframe | CMS signal |
|-----------|-----------|
| Risposta preimpostata (single) | `possible_answer.type = radio` |
| Risposta preimpostata (multi) | `type = checkbox` (+ `deselect_others`, `is_other`) |
| Risposta libera | `type = input` (`input_type` text/date, `other_validations`) |
| Scala 0–N | `type = scale` (`scale_values`, `initial_label`/`final_label`) |
| Testo informativo / Intermezzo / Intro piattaforma | no `possible_answer`, `use_custom_cta` optional |
| Risultato kit/tipo | `use_custom_cta`, title templated `{{name}}` `{{type}}` `{{product}}` |
| Prova d'acquisto | `input` + `single_product_barcode_check` / `show_single_product_cta` |
| Dropdown | `show_as_dropdown` |
| Branching (gravidanza/menopausa) | `conditions` + `condition_action`; e.g. shown only if gender `_eq` option `id:97` (Femmina) |

## Submit contract — confermato dal backend

Confermato da **Daniele Pastori** con una fixture reale (domande originali in
[[survey-domande-backend]]). Implementato in `buildSubmitBody`
(`lib/features/survey/data/survey_mapper.dart`), con regression test in
`test/features/survey/data/survey_submit_body_test.dart`.

1. **Chiave `steps`** = l'**id della domanda** (`survey_sections.possible_answer.id`), **non**
   l'id sezione. Ogni step contiene anche `sectionId` (id sezione) e `storeToField`.
2. **`storeToField`** = `survey_sections.user_data_field_name` **solo se**
   `store_in_user_data === true`, altrimenti `null`. Gli step vanno inviati **anche con
   `storeToField: null`** (servono al calcolo dell'outcome/biotipo). Le sezioni senza
   `possible_answer` (info/intermezzo/risultato) **non** producono step.
3. **`answer`** — `radio` → oggetto singolo `{ id, value_to_store }`; `checkbox` → array di
   quegli oggetti; opzione "Altro" → `{ id, is_other: true, other_value }`. `input`/`scale` →
   scalare grezzo. Data di nascita → ISO `yyyy-MM-dd`. `sectionId`/`id` sono **numerici**.
4. **`bmi`** = peso(kg) / altezza(m)² come **float**; **`ageValue`** = anni interi dalla dob.
5. **Risultato kit/biotipo** — tutto nella risposta del submit (`outcome`, `kit_shop_url`).
6. **Ordine flussi** — deciso da `profile_status` (`/survey/me/status`): `initial_survey` →
   `type_survey`, poi `starter_kit`, ecc. **`pharmacy_data`** = oggetto della farmacia scelta
   (`{ id, title, city, address, … }`); **`single_product_id`** = ID numerico del prodotto
   scelto nel dropdown di `starter_kit`.

Esempio di body reale (fixture):

```json
{
  "bmi": 22,
  "ageValue": 22,
  "pharmacy_data": null,
  "single_product_id": null,
  "steps": {
    "10": { "sectionId": 100, "storeToField": "gender", "answer": { "id": 1, "value_to_store": "f" } },
    "11": { "sectionId": 101, "storeToField": null,     "answer": { "id": 501, "value_to_store": "1" } }
  }
}
```

**`pharmacy_data` e `single_product_id` — cablati.**
- `pharmacy_data`: le sezioni `load_kilocal_points` mostrano un **picker farmacia** con ricerca
  server-side sulla collection `pharmacies` (22k+ righe, param GraphQL `search` su
  nome/città/provincia). La farmacia scelta viene inviata come oggetto
  `{ id, title, address, city, province, zip, region, store_id }`. Il CTA dello step è bloccato
  finché non se ne seleziona una.
- `single_product_id`: deriva dalla risposta alla domanda prodotto `show_as_dropdown`
  (`single_product_survey`); l'`value_to_store` dell'opzione scelta è l'ID numerico del prodotto
  (es. `Kilocal AGE Menopausa` → `23`).

## Wizard UI — navigazione tra step

Il wizard (`SurveyScreen` / `SurveyCubit`) tiene le risposte in `state.answers`
keyed by `section.id`; la navigazione avanti/indietro **non** le cancella. Un
bug di sola presentazione le faceva però "trascinare" tra step consecutivi: i
campi input (`SurveyTextField`, `SurveyDateField`, il "Specifica" dell'`is_other`)
e le chip (`SurveyOptionChip` in `AnimatedContainer`) occupavano la stessa
posizione nell'albero, così Flutter ne riusava `State`/`Element` — il testo del
passo precedente riappariva e la chip lampeggiava un frame nel vecchio stato
"selezionato".

**Fix (commit `5e8573a`):** ogni input riceve una key per sezione, così ogni
step ha un'identità widget distinta:

- `SurveyTextField` / `SurveyDateField` → `ValueKey('survey-text|date-${section.id}')`
- `SurveyOptionsList` → `ValueKey('survey-options-${section.id}')`; il suo campo
  libero `is_other` prende un `otherFieldKey` (`survey-other-${section.id}`)
- ogni chip → `ValueKey('survey-chip-${option.id}')`

Regola generale per nuovi input nel wizard: **keyarli per `section.id`** (o
`option.id`) per evitare il riuso di stato tra step. Richiede hot **restart** in
sviluppo (le key cambiano l'albero).

## Related

- [[survey-domande-backend]]

- [[authentication]]
- [[profilo]]
- [[profilo-read]]
- [[graphql]]
- [[missing-apis]]
