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

## Endpoints

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/journal/goals` | list goals |
| POST | `/journal/goals` | create |
| PATCH | `/journal/goals/{id}` | update |
| DELETE | `/journal/goals/{id}` | delete (`204`) |

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
`400` bad body · `403` not owner · `404` not found.

## Resolves missing-apis §4

Replaces the proposed `/api/diary*` in [[missing-apis]] §4. The achievements **history** is
[[diario-attivita|GraphQL on `user_activities`]], not a REST GET.

## Related

- [[diario-attivita]]
- [[strumenti]]
- [[overview]]
- [[missing-apis]]
