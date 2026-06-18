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
