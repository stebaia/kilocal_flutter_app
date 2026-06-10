# Settings

Returns the global shop configuration (menu, strings, footer).

## Get settings

```
GET /api/settings
```

- Authentication: **no**

### Response 200

```json
{
  "settings": {
    "main_menu": { "...": "..." },
    "footer_menu": { "...": "..." },
    "generic_strings": { "...": "..." }
  }
}
```

On error, returns `{ "settings": {} }` (no error status code).

## Related

- [[overview]]
- [[authentication]]
