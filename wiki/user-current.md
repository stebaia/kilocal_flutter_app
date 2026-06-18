# Current user — `GET /users/me`

Native Directus route. Bearer token required. Source: Swagger *Kilocal App*.

## `GET /users/me`

Returns the authenticated Directus user. Use the `fields` query param to project:

```
GET /users/me?fields=id,email,first_name,last_name,role.name
```

Response: `{ "data": { … } }` (shape depends on `fields`). `401` if token missing/invalid.

> **`id` is the `myId`** used as a variable in most GraphQL profile/percorso queries
> (e.g. [[profilo-read|`GetUserDetails`]]). Fetch it once after login and cache it.

## Related

- [[authentication]]
- [[profilo-read]]
- [[profilo]]
