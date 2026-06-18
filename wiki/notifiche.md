# Notifiche / inbox (GraphQL read + write)

Collection `user_notifications`. App channel: `job_channel: web_app` (push FCM/APNs **not
implemented**). Read + mark via [[graphql]]. Fields verified against the SDL.
Source: Swagger *Kilocal App*.

## Tabs (filters)

| Tab | Filter |
|-----|--------|
| Non lette | `read_on` null, `archived_on` null, `job_status: completed`, `job_channel: web_app` |
| Lette | `read_on` not null, `archived_on` null |
| Archiviate | `archived_on` not null |

## Unread badge

`user_notifications_aggregated` with the *Non lette* filter → `count { id }`. Feeds the
bottom-bar badge.

## Fields (`user_notifications`)

| Field | Type | Notes |
|-------|------|-------|
| `id` | Int | |
| `created_on` | Date | |
| `read_on` | Date | null = unread |
| `archived_on` | Date | null = not archived |
| `job_status` | String | `completed` for deliverable |
| `job_channel` | String | `web_app` for the app |
| `job_payload` | JSON | Liquid template (html, title, cta) — **render client-side** |
| `notification` / `notification_shop` | relation | source notification config |

## Query

```graphql
query GetUserNotificationsPaginated($filter: user_notifications_filter, $page: Int = 1) {
  user_notifications(filter: $filter, page: $page, sort: ["-created_on"]) {
    id created_on read_on archived_on job_channel job_payload
  }
}
```

## Mark read / archive (mutation)

`update_user_notifications_item` with `read_on` or `archived_on` (Date). Swipe-to-archive →
set `archived_on`.

## Resolves missing-apis §8

Replaces the proposed `GET /api/notifications` / `PATCH /api/notifications/{id}` in
[[missing-apis]] §8. **Push is not implemented** — inbox only.

## Related

- [[graphql]]
- [[missing-apis]]
