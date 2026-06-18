# Users

Registration and password management. Login itself is covered in [[authentication]].

## Registration

```
POST /api/users
```

- Authentication: **no**

Body:
```json
{
  "first_name": "Mario",
  "last_name": "Rossi",
  "email": "mario@example.com",
  "password": "********",
  "password_confirm": "********",
  "privacy": true,
  "newsletter": false,
  "is_platform_user": false
}
```

Response 200: created Directus user object (role `User`, `registered_from: shop`).

| HTTP | statusMessage |
|------|---------------|
| 400 | `Email is required` |
| 400 | `Passwords do not match` |

## Forgotten password

```
POST /api/auth/password-forgotten
```

Body: `{ "email": "mario@example.com" }`

Response 200: `{ "status": "ok" }` (always returned, even if the email does not exist — for
privacy). Generates a reset token and starts the email flow via Directus.

| HTTP | statusMessage |
|------|---------------|
| 400 | `EMAIL_REQUIRED` |

## Reset password

```
POST /api/auth/password-reset
```

Body:
```json
{
  "token": "reset-token-from-email",
  "password": "nuovaPassword",
  "password_confirm": "nuovaPassword"
}
```

Response 200: `{ "status": "ok" }`

| HTTP | statusMessage |
|------|---------------|
| 400 | `TOKEN_REQUIRED` |
| 400 | `PASSWORDS_DO_NOT_MATCH` |
| 400 | `NO_USER_FOUND_BY_RESET_TOKEN` |

> ⚠️ Error message casing/format is inconsistent across endpoints (`Passwords do not match` vs
> `PASSWORDS_DO_NOT_MATCH`). See [[contradictions]].

## Related

- [[authentication]]
- [[user-addresses]]
