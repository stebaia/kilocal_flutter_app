# Notifications — implementation plan (mock → dynamic)

> **Aggiornato 2026-06-19.** Piano per dinamicizzare la schermata `notifications`, verificato
> contro lo **Swagger/SDL reale** dello staging (`https://cms-stg.kilocal.thefullproject.it`).
> Lo Swagger ha priorità assoluta sul wiki. **Nessuna dipendenza da `percorsi*`/backend aperto —
> implementabile SUBITO.** Vedi [[notifiche]], [[graphql]].

## 0. Verifica API (cosa esiste DAVVERO)

Sorgenti controllate il 2026-06-19 (SDL pubblico `GET /server/specs/graphql`):

| Elemento | Verificato | Esito |
|----------|-----------|-------|
| `user_notifications` (read) | SDL | ✅ esiste |
| `user_notifications.{id,read_on,archived_on,created_on,notification_event,job_channel}` | SDL | ✅ esiste |
| `user_notifications.notification` (relazione → `notifications`) | SDL | ✅ esiste (tipo/asset) |
| `user_notifications.translations.{title,content,content_url}` | SDL | ✅ esiste (i18n) |
| `update_user_notifications_item(id, data)` | SDL Mutation | ✅ esiste (write `read_on`/`archived_on`) |
| `create_*` / `delete_*` su user_notifications | SDL | ❌ assenti (corretto: le crea il backend) |

### Conseguenze (verità operativa)

1. **Read+write entrambi confermati** nell'SDL pubblico → zero dipendenze esterne, nessuna
   domanda al backend. Stesso pattern GraphQL di `home_repository_impl.dart`.
2. **Testo localizzato** via `translations(filter: { languages_code: { code: { _eq: $lang } } })`
   — identico al filtro lingua già usato dalla home (`home_repository_impl.dart:32`).
3. **Lo stato "archiviata"/"letta" si SCRIVE** con `update_user_notifications_item` impostando
   `archived_on`/`read_on` a `now()` — non c'è delete. Il cubit oggi fa `archive()` solo in
   memoria (`notifications_cubit.dart:25`): va collegato alla mutation.
4. **Immagine/CTA**: `NotificationType` (plain/withImage/withCta) si deriva da
   `notification.* ` + `translations.content_url`. Mappare nel repository.

## 1. Scope

**IN scope:**
- Lista notifiche reali dell'utente (escludendo le `archived_on != null`), ordinate per
  `created_on` desc, testo localizzato.
- **Archivia** → `update_user_notifications_item { archived_on: now }` con update ottimistico.
- **Segna come letta** → `read_on` (al tap / apertura dettaglio).

**FUORI scope (rinviato):**
- Filtro (icona `notifications_screen.dart:41`, oggi TODO) → cablabile dopo, lato client.
- Push notifications: non implementate lato backend (`job_channel: web_app`), vedi [[notifiche]].

## 2. Modifiche file

### Domain (nuovo — la feature oggi ha solo entità + presentation)
- `domain/entities/notification_item.dart` — invariato (già adeguato: id/title/body/timestamp/
  type/imageUrl/ctaLabel/archived). Eventuale aggiunta `read` se serve in UI.
- `domain/notifications_repository.dart` (nuovo) —
  - `Future<List<NotificationItem>> fetchNotifications({required String myId})`
  - `Future<void> archive(String id)`
  - `Future<void> markRead(String id)`

### Data (nuovo)
- `data/dto/notification_dto.dart` (+ `.g.dart`) — `json_serializable`.
- `data/notifications_repository_impl.dart` (nuovo) — su `GraphqlClient`:
  - query `user_notifications(filter: { user: { id: { _eq } }, archived_on: { _null: true } },
    sort: ["-created_on"])` con `translations` + `notification { ... }`,
  - mutation `update_user_notifications_item` per archive/markRead,
  - mapping `NotificationType` da campi notification/content_url,
  - error-mapping `ApiException.fromDio` (pattern home).

### Presentation
- `presentation/cubit/notifications_cubit.dart` — iniettare `NotificationsRepository` +
  `UserCubit` (per `myId`); `load()` chiama il repository; `archive()` → update ottimistico +
  chiamata repository con rollback su errore. Aggiungere `markRead(id)`.
- `presentation/notifications_screen.dart:17,21` — `getIt<NotificationsCubit>()..load()`;
  rimuovere `MockDataFactory.notifications`.

### DI
- `lib/app/di.dart` — registrare `NotificationsRepository` (lazySingleton) e
  `NotificationsCubit` (factory con `userCubit`), sul modello Home/Path.

### Cleanup
- Rimuovere `MockDataFactory.notifications` (verificare che non sia usato altrove).

## 3. Verifica
1. `dart analyze` + `dart format` (agent `dart-linter`).
2. Run manuale: lista reale; archivia una notifica → sparisce e resta archiviata al reload.
3. Test cubit: `load`, `archive` ottimistico + rollback su errore.

## 4. Dipendenze / rischi
- **Nessuna dipendenza dal backend aperto** (a differenza di [[path-implementation-plan]] /
  [[statistics-implementation-plan]]). Implementabile da subito via `api-integrator`.
- Unica verifica a runtime: confermare i nomi dei campi `notification.*` (tipo/asset) col token
  reale — ma sono nello SDL, rischio basso.

## Stato
- **2026-06-19** — Piano scritto e verificato contro SDL staging. **SBLOCCATO**, pronto per
  l'implementazione via `api-integrator`.

## Related
- [[notifiche]]
- [[graphql]]
- [[home-implementation-plan]]
