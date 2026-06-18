# Survey & onboarding

`survey` extension. Drives onboarding and the user profile (`user_details`). Bearer token
required; send `X-Kilocal-Origin: app`. Source: Swagger *Kilocal App*.

## Endpoints

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/survey/me/status` | onboarding state + completed surveys |
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

> **Survey questions** (sections, options, conditions) are **read** via [[graphql]] on the
> `surveys` / `survey_sections` / `survey_question` collections — there is no dedicated REST
> GET. This resolves the proposed `GET /api/survey/{type}` in [[missing-apis]] §1.

## Related

- [[authentication]]
- [[profilo]]
- [[profilo-read]]
- [[graphql]]
- [[missing-apis]]
