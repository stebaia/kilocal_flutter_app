# Diario — traguardi/goals (REST writes)

`journal` extension. **Write** side of the diary: personal goals/achievements. The activity
**history** (completed steps) is read via GraphQL — see [[diario-attivita]]. Bearer token
required. Source: Swagger *Kilocal App*.

## What counts as a "goal"

`user_reminders` rows that have a `category` **or** a `related_goal` — i.e. diary objectives,
**excluding** the calendar reminders handled by [[strumenti]] `/tools/reminders`.

| Goal type | Driven by |
|-----------|-----------|
| Personal objective | `category` (→ `goal_categories`) |
| Predefined achievement | `related_goal` (→ catalog `goals`) |

## Kilocal goals are materialised by a reconcile (confirmed 2026-08-11)

The predefined Kilocal goals are **not** created by the app. Both
`GET /journal/goals` **and** [[survey|`GET /survey/me/month-end-status`]] run a
**reconcile** server-side: they materialise the goals the user has unlocked and
auto-complete the per-area ones that have reached 100%. Either call is enough —
the Traguardi page doesn't strictly need month-end-status first, though calling it
stays harmless (and keeps the pending-survey state fresh).

### Four goals per month

| Slug | Kind |
|------|------|
| `primo_mese_allenamento` | per-area |
| `primo_mese_alimentazione` | per-area |
| `primo_mese_integrazione` | per-area |
| `traguardo_mese_1` | generic |

Month **N+1**'s goals only appear once **all four** of month N's goals have a
`completed_at`. So the list grows a month at a time; the absence of month 2/3 goals is
expected state, not a gap.

### How each kind completes

- **Per-area** goals are auto-completed by the reconcile when that area hits 100%.
- The **generic** goal is closed by submitting the month-end survey
  (`POST /survey/submit/month_end_survey_N`).

A month-end survey is reported **pending** only when `allenamento` +
`alimentazione` + `integrazione` are all at 100% for that month. **Benessere does not
count** toward it.

> Earlier docs said "month complete = integrazione phase at 100%" and that only the
> generic `traguardo_mese_N` goals exist. Both are superseded by the above.

No client-side filter is needed: the list returns `category` OR `related_goal` rows,
and the app already splits them by which field is set.

## Kilocal goals can't be deleted

`DELETE /journal/goals/{id}` on a Kilocal goal (one carrying `related_goal`) returns
**`403`** — the server refuses it. Manual completion via `PATCH` is allowed, and
completed Kilocal goals **stay in the list** (they're never removed, only flagged).

The client already reflects this: `diary_goal_detail_sheet.dart` only offers
"Elimina traguardo" for `DiaryGoalKind.personal`, so the delete call is unreachable
for Kilocal goals.

## Endpoints

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/journal/goals` | list goals — **also reconciles** (materialises unlocked goals, auto-completes per-area ones at 100%) |
| POST | `/journal/goals` | create |
| PATCH | `/journal/goals/{id}` | update (also used to complete: set `completed_at`) |
| DELETE | `/journal/goals/{id}` | delete (`204`) — **`403` on Kilocal goals** (`related_goal` set) |

`UserGoal` extends `UserReminder` (see [[strumenti]]) with:

```json
{
  "id": "uuid",
  "content": "…",
  "due_date": "2026-06-30",
  "due_time": "…",
  "completed_at": null,
  "redirectTo": null,
  "category": 4,
  "related_goal": null
}
```

`UserGoalInput` extends `UserReminderInput` with `category` and/or `related_goal`.
`category` is required for personal objectives when `related_goal` is absent (and vice-versa).
`400` bad body · `403` not owner **or Kilocal goal deletion** · `404` not found.

## Resolves missing-apis §4

Replaces the proposed `/api/diary*` in [[missing-apis]] §4. The achievements **history** is
[[diario-attivita|GraphQL on `user_activities`]], not a REST GET.

## Related

- [[diario-attivita]]
- [[strumenti]]
- [[overview]]
- [[missing-apis]]
