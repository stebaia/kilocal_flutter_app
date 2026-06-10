# User Addresses

CRUD for user addresses. All endpoints require [[authentication]]; a user can only operate on
their own addresses.

## Create address

```
POST /api/user-addresses
```

Body:
```json
{
  "first_name": "Mario",
  "last_name": "Rossi",
  "company": "",
  "country": "it",
  "address": "Via Roma 1",
  "city": "Milano",
  "province": "MI",
  "zip": "20100",
  "phone": "+39 333 1234567",
  "is_default": false
}
```

Response 200: `{ "data": { ...indirizzo } }`

## Update address

```
PATCH /api/user-addresses/{id}
```

Body: same fields as create (partial allowed).

Errors: `401 Unauthorized`, `403 Forbidden` (another user's address).

## Delete address

```
DELETE /api/user-addresses/{id}
```

Response 200: `{ "data": { "id": "..." } }`

## Related

- [[orders]]
- [[cart]]
- [[users]]
- [[authentication]]
