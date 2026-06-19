# Path — implementation plan (mock → dynamic)

> **Aggiornato 2026-06-19.** Piano per dinamicizzare la feature `path`, verificato contro lo
> **Swagger/SDL reale** dello staging (`https://cms-stg.kilocal.thefullproject.it`). Lo Swagger
> ha priorità assoluta sul wiki. Vedi [[percorso-read]], [[percorso]], [[contradictions]].

## 0. Verifica API (cosa esiste DAVVERO)

Sorgenti controllate il 2026-06-19:
- OpenAPI generato da Directus: `GET /server/specs/oas` (200, 442 path)
- SDL GraphQL pubblico: `GET /server/specs/graphql` (200)

| Elemento | Verificato nello spec | Esito |
|----------|----------------------|-------|
| `user_details.active_timeframe` | SDL → `Int` | ✅ esiste |
| `user_details.percorso_allenamento_curr_step` | SDL → `Int` | ✅ esiste (numero step) |
| `user_details.percorso_alimentazione_curr_step` | SDL → `Int` | ✅ esiste |
| `user_details.percorso_benessere_curr_step` | SDL → `Int` | ✅ esiste |
| `user_details.percorso_integrazione_curr_phase` | SDL → `product_phases` | ✅ esiste (FASI, non step) |
| `user_details.old_percorso_completed` | SDL → `Boolean` | ✅ esiste |
| `user_activities` (`id/started_on/completed_on/activity`) | SDL | ✅ esiste |
| `user_activities.activity[].item` (M2A polimorfico) | SDL → `user_activities_activity.item: String` | ✅ esiste |
| `user_activities_aggregated` | SDL | ✅ esiste |
| `percorsi` / `percorsi_groups` / `percorsi_content` | **assenti** dall'SDL pubblico | ⚠️ auth-gated, non verificabili da qui |
| `percorsi_content_aggregated` | **assente** dall'SDL pubblico | ⚠️ auth-gated |
| `POST /path/steps/{id}/start` · `/complete` | **assenti** dall'OAS pubblico | ⚠️ tab "Kilocal App", non nello spec generato |

### Conseguenze (verità operativa)

1. **`curr_step` è un `Int` nell'SDL pubblico**, ma `home_repository_impl.dart:30` lo interroga
   come oggetto (`{ id sort translations asset }`). Questo funziona **solo** perché il ruolo
   autenticato rimappa il campo a una relazione (modello content-access, [[authentication]]).
   → Le stesse query funzioneranno per `path` **se e solo se** la home dinamica restituisce dati
   reali col token corrente. **La home funzionante è la prova che il pattern regge.**
2. **`percorsi*` e gli endpoint `/path/steps/*` non sono verificabili staticamente.** Vanno
   trattati come *contratto dallo Swagger "Kilocal App"*, non garantiti dallo spec generato.
3. **Strategia di rischio:** costruire l'overview SOLO sui campi confermati nell'SDL
   (`*_curr_step`, `active_timeframe`, `user_activities[_aggregated]`) — gli stessi della home.
   Le query strutturali (`percorsi_groups`/`percorsi_content`) e le scritture REST restano
   FUORI da questo giro, dietro metodi-stub nel repository, finché non c'è la schermata di
   dettaglio area e una verifica col token.

## 1. Scope

**IN scope (overview, campi confermati):**
- 4 card area (`allenamento`, `alimentazione`, `benessere`, `integrazione`) con progressi reali.
- Totale complessivo `overallCompleted / overallTotal`.

**FUORI scope (rinviato, non verificabile dallo spec pubblico):**
- Dettaglio area / lista step (`percorsi_groups` + `percorsi_content`).
- Scritture `POST /path/steps/{id}/start|complete` → solo firme stub nel repository.
- `integrazione` start/complete (usa fasi via `update_user_details_item`, [[integrazione]]).

## 2. Calcolo progressi (solo SDL confermato)

Per ciascuna delle 3 root a step (`allenamento`/`alimentazione`/`benessere`):
- **completed** = conteggio `user_activities` con `completed_on { _nnull: true }` la cui
  `activity[].item` appartiene alla root. Stesso meccanismo M2A di
  `home_repository_impl.dart:99` (filtro per `timeframe.sort`).
- **total** = via `percorsi_content_aggregated` filtrato per root/timeframe (come la home, riga
  90). ⚠️ collezione auth-gated → fallback al conteggio noto se la query non risponde.
- **currentStepSort** = `percorso_<root>_curr_step` (Int) da `user_details`.

`integrazione`: progresso a fasi da `percorso_integrazione_curr_phase` (relazione
`product_phases`), senza step.

## 3. Modifiche file

### Domain
- `domain/entities/path_data.dart` — aggiungere a `PathArea`: `internalName` (root), `currentStepSort`.
- `domain/path_repository.dart` — nuova firma
  `fetchPath({required String myId, required int activeTimeframe, required AppLocalizations l10n})`;
  aggiungere stub `Future<void> startStep(String stepId)` e
  `Future<void> completeStep({required String stepId, required String percorsoInternalName})`
  (implementati ma non cablati alla UI).

### Data
- `data/dto/path_area_progress_dto.dart` (+ `.g.dart`) — `json_serializable`, come `home/data/dto`.
- `data/path_repository_impl.dart` — riscrivere su `GraphqlClient` + `Dio`:
  - query aggregati per le 3 root (riuso schema `home_repository_impl.dart:90`),
  - lettura `*_curr_step` + `active_timeframe` da `user_details`,
  - mapping root→asset/titolo l10n preso dal mock attuale,
  - `startStep`/`completeStep` via `dio.post('/path/steps/$stepId/...')`, body
    `{percorsoInternalName}`, error-mapping `ApiException.fromDio` (NON cablati: dietro stub).
- **eliminare** `data/path_mock_data_factory.dart`.

### Presentation
- `presentation/cubit/path_cubit.dart` — iniettare `UserCubit` (come `HomeCubit`); ricavare
  `myId` + `activeTimeframe`; gestire `user == null`. Esporre `startStep`/`completeStep`.
- `presentation/path_screen.dart:25` — `getIt<PathCubit>()..load()` (niente `l10n` al load:
  passato al repository tramite il cubit).

### DI
- `lib/app/di.dart:97-99` —
  `PathRepositoryImpl(graphqlClient: getIt(), dio: getIt())` (non più `const`),
  `PathCubit(pathRepository: getIt(), userCubit: getIt())`.

## 4. Verifica
1. `dart analyze` + `dart format` (agent `dart-linter`).
2. Run manuale schermata path: confronto progressi con la home (devono concordare sui
   timeframe).
3. **Probe col token reale** (prima di cablare le scritture): `percorsi_groups`/`percorsi_content`
   + `POST /path/steps/*` — solo allora aprire il dettaglio area in un secondo PR.

## 5. Domande aperte al backend (BLOCCANTI prima di implementare)

Inviate al team il 2026-06-19. Implementazione **in attesa di risposta**.

1. **Conteggio completati/totali per area.** Come si risale da uno `user_activity` completato
   (`completed_on` valorizzato) alla root di appartenenza (`percorsi_content` → root)? E qual è
   il filtro per il **totale step** di un'area? `percorsi_content_aggregated` non è nell'SDL
   pubblico — risponde col token dell'app?
2. **Scope del progresso.** La barra complessiva ("23/132" nel mock) è sull'intero percorso o
   solo sul `active_timeframe` corrente?
3. **Integrazione = fasi, non step.** Come mostrare `completati/totale` per `integrazione`
   (`percorso_integrazione_curr_phase` → `product_phases`)? `product_phases` non ha un campo
   "numero totale fasi" né `internal_name`: come si ricava il totale fasi del prodotto utente?
4. **`curr_step` Int vs oggetto.** Nello SDL `percorso_*_curr_step` è `Int`, ma la home lo
   interroga come oggetto (titolo/asset) e funziona. È il ruolo autenticato che lo rimappa a
   `percorsi_content`? Comportamento stabile?

> Il messaggio in forma discorsiva per il team è stato preparato in chat (2026-06-19), basato
> su queste 4 domande + la query GraphQL già usata dalla home come riferimento.

## Stato

- **2026-06-19** — Piano scritto e verificato contro Swagger/SDL staging. Domande inviate al
  backend. **Prossimo passo:** alla risposta, implementare l'overview (Fasi 1-5) via
  `api-integrator`. Le scritture REST e il dettaglio area restano a un secondo PR.

## Related
- [[percorso-read]]
- [[percorso]]
- [[contradictions]]
- [[home-implementation-plan]]
- [[graphql]]
