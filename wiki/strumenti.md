# Strumenti — reminders & photo gallery (REST writes)

`tools` extension. **Write** side of the tools hub. Read-only config (timer, glossary, photo
list, tool blocking) is GraphQL — see [[strumenti-read]]. Bearer token required.
Source: Swagger *Kilocal App*.

The tools hub groups four tools: **Promemoria**, **Timer**, **Glossario**, **Foto progressi**.
Timer and Glossario are read-only (config from CMS, countdown is local) → [[strumenti-read]].

## Promemoria (calendar reminders)

Reminders **without** `category` (calendar items, distinct from diario goals which live on
[[diario]]).

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/tools/reminders` | list reminders |
| POST | `/tools/reminders` | create |
| PATCH | `/tools/reminders/{id}` | update |
| DELETE | `/tools/reminders/{id}` | delete (`204`) |

`UserReminder`:

```json
{
  "id": "uuid",
  "content": "Bere acqua",
  "due_date": "2026-06-20",
  "due_time": "08:30",
  "completed_at": null,
  "redirectTo": null
}
```

`UserReminderInput` = `{ content, due_date, due_time, completed_at?, redirectTo? }`.
`403` if the reminder is not the caller's · `404` if not found.

### ⚠️ BACKEND BUG — duplicate reminders on future months (reported 2026-07-26)

A single `POST /tools/reminders` for one date is coming back, on subsequent `GET
/tools/reminders`, as **multiple rows** — same `content`/`due_time`, but one per
month going forward on the same day-of-month (e.g. create on Aug 3 → also appears
on Sep 3, Oct 3, …). Confirmed this is **not** a client-side bug:

- The Flutter app sends exactly one `POST` per creation (see
  `PromemoriaRepositoryImpl.add` in `lib/features/strumenti/promemoria/data/
  promemoria_repository_impl.dart`) — no recurrence logic, no loop.
- The month filter (`PromemoriaState.remindersInMonth`) correctly matches on
  **both** `year` and `month`, not just day-of-month — so if duplicates show up
  across months in the app, the extra rows are already present in what `GET
  /tools/reminders` returns.

Needs investigating server-side: does `POST /tools/reminders` (or some scheduled
job on the `tools` extension) materialise recurring rows for calendar reminders,
similar to how [[diario]]'s `traguardo_mese_N` goals are auto-created monthly? If
so, that behavior needs to be scoped to goals only, not calendar reminders — a
user-created one-off reminder should never multiply across future months.

## Foto progressi (photo gallery)

| Method | Path | Purpose |
|--------|------|---------|
| POST | `/tools/photo-gallery` | upload a photo (`multipart/form-data`, field `file`) |
| DELETE | `/tools/photo-gallery` | delete, body `{ "fileId": "<uuid>" }` |

Upload response:

```json
{ "data": { "fileId": "uuid", "userPhotoId": "uuid" } }
```

Delete response: `{ "success": true }`.

> **Listing photos** is GraphQL on `user_photos` (sort `-date_created`, nested `file`) — see
> [[strumenti-read]]. These are body-progress photos: private storage, always authenticated.

## Resolves missing-apis §10

This replaces the proposed `/api/reminders/*` and `/api/progress-photos/*` in [[missing-apis]]
§10.1 / §10.4. Timer (§10.2) is confirmed client-side; Glossario (§10.3) is GraphQL.

## Related

- [[strumenti-read]]
- [[diario]]
- [[overview]]
- [[missing-apis]]
