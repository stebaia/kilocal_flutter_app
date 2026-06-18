# Profilo — update (REST write)

`profile` + `survey` extensions. **Write** side of the profile. The read side is GraphQL —
see [[profilo-read]]. Bearer token required. Source: Swagger *Kilocal App*.

## `PATCH /profile`

Updates `directus_users`, `user_addresses` and `user_details` **in one call**.

Body (`ProfileUpdateBody`, free-form — fields routed by name):

| Target collection | Fields |
|-------------------|--------|
| `directus_users` | `first_name`, `last_name`, `email` |
| `user_addresses` | `province`, `zip`, `city`, `address`, `phone` |
| `user_details` | everything else (`weight`, `height`, `gender`, `newsletter`, …) |

Response: `{ "success": true }`. `401` no token · `404` `user_details` not found.

## Reading the profile

- Full profile → [[profilo-read|GraphQL `GetUserDetails`]] on `user_details` + `user_addresses`
  (variable `myId` from `GET /users/me`).
- Onboarding state → [[survey|`GET /survey/me/status`]].

## Resolves missing-apis §9

Replaces the proposed `GET/PATCH /api/profile` and `GET /api/profile/silhouette` in
[[missing-apis]] §9. The "silhouette / biotype" is derived from `user_details`
(`gender`, `profile`, percorso fields) read via GraphQL — no dedicated endpoint.

## Related

- [[profilo-read]]
- [[survey]]
- [[user-current]]
- [[overview]]
