# Error responses

Shared error shapes from the Swagger *Kilocal App* spec.

## `ErrorResponse` (Directus standard)

```json
{
  "errors": [
    { "message": "…", "extensions": { "code": "FORBIDDEN" } }
  ]
}
```

Used by `401 Unauthorized`, `403 Forbidden`, and most failures. Switch on
`errors[0].extensions.code`, not on `message`.

## `400 BadRequest`

`oneOf`:

- the `ErrorResponse` shape above, **or**
- a flat `{ "error": "…" }` string.

Clients must tolerate **both** on `400`.

## Status codes by area

| Code | Meaning |
|------|---------|
| `401` | token missing or invalid → re-`/auth/refresh`, then re-login |
| `403` | insufficient permission (e.g. role not User, or content blocked) |
| `400` | invalid payload |
| `404` | resource not found (e.g. `user_details`, activity, reminder) |
| `409` | conflict (e.g. email already registered) |

## GraphQL errors

`POST /graphql` returns `200` even on logical errors; check the top-level `errors` array in
the body (Directus convention), alongside `data`. See [[graphql]].

## Related

- [[authentication]]
- [[graphql]]
- [[overview]]
