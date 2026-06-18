# Strumenti — config & photo list (GraphQL read)

Read-only side of the tools hub. Writes (reminders, photo upload) → [[strumenti]]. Via
[[graphql]]. Source: Swagger *Kilocal App*.

## Config hub

Query the singletons `timer`, `reminders`, `photo_gallery`, `glossary_tool` for translations,
assets, and `is_tool_blocked`.

> **Blocking:** a tool is blocked (`is_tool_blocked`) when
> `profile_status = active_restricted_access`. See [[authentication]].

## Timer

CMS provides **config only** (e.g. ringtone list, labels). The countdown/stopwatch runs
**locally** in the app — no API. Confirms [[missing-apis]] §10.2 (client-side).

## Glossario

```graphql
query GetGlossary($filter: glossary_filter) {
  glossary(filter: $filter, sort: ["sort"]) {
    id shortcut_code
    translations { languages_code { code } title definition }
  }
}
```

Optional search filter on the translated term. Resolves [[missing-apis]] §10.3.

## Photo gallery (list)

`user_photos`, sort `-date_created`, nested `file`. Fields: `id`, `date_created`, `sort`,
`file { id }`, `user`.

```graphql
query GetUserPhotos {
  user_photos(sort: ["-date_created"]) {
    id date_created file { id width height }
  }
}
```

Upload / delete → [[strumenti]] `/tools/photo-gallery`.

## Related

- [[strumenti]]
- [[graphql]]
- [[authentication]]
- [[missing-apis]]
