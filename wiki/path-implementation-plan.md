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

## 2. Calcolo progressi (CONFERMATO dal backend, Daniele Pastori 2026-06-19)

### 3 root a step (`allenamento`/`alimentazione`/`benessere`)

**Passo 1 — mappa `stepId → area`** (una sola query, risolve il "totale per area"):
```graphql
percorsi(sort: "order") {
  root { internal_name }
  groups(filter: { is_percorso_main_tab: { _eq: true } }) {
    steps(sort: "percorsi_content_id.sort") {
      percorsi_content_id { id timeframe { id } }
    }
  }
}
```
- **total** per area = numero di `steps` di quell'area.
- **completed** per area = quanti di quegli `stepId` compaiono con `completed_on` valorizzato
  nelle `user_activities` dell'utente.
- **currentStepSort** = `percorso_<root>_curr_step` (Int) da `user_details`.

> ✅ Risolve la vecchia incertezza su `percorsi_content_aggregated`: NON serve, si conta dalla
> mappa. `percorsi`/`groups`/`steps` sono auth-gated ma confermati funzionanti col token.

### `integrazione` — NON a fasi, ma a giorni di assunzione

Diverso dalle altre 3. Si traccia con `user_integratori.took_dates` (giorni presi). Il
**totale** (durata) si ricava dal kit dell'utente:
```graphql
# kitId = user_details.profile_kit
kit_products(filter: { kit: { id: { _eq: $kitId } } }) {
  phase { id sort }
  only_for_gender          # valorizzato se la fase è specifica uomo/donna
  products_with_duration {
    kit_products_duration_id { duration product { id } }
  }
}
```
- total = somma/durata delle fasi del kit; **media** se ci sono più prodotti.
- `only_for_gender` → filtrare per il gender dell'utente quando valorizzato.
- completed = numero di `took_dates` in `user_integratori`.

> ⚠️ `integrazione` è sensibilmente più complessa. Daniele si è offerto di **creare un endpoint
> REST dedicato** se la query diventa ingestibile → vedi §5. **Decisione consigliata: chiedere
> l'endpoint REST per integrazione** e tenere GraphQL solo per le 3 root a step.

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

## 5. Risposte del backend (Daniele Pastori, 2026-06-19) → quasi tutto risolto

1. ✅ **RISOLTA.** Mappa `stepId → area` via `percorsi { root.internal_name, groups, steps }`
   (vedi §2). Totale = nº step dell'area; completati = step con `completed_on`. Niente
   `percorsi_content_aggregated`.
2. 🟡 **In attesa di conferma da Francesco Galatro.** "Su web ho solo quelle eseguite, ma credo
   sia il totale di tutto il percorso." → assumere **totale intero percorso**, confermare.
3. ✅ **RISOLTA (ma complessa).** `integrazione` = giorni di assunzione (`user_integratori.took_dates`),
   non fasi. Totale/durata da `user_details.profile_kit` → `kit_products` (vedi §2). Media se
   più prodotti; filtrare per `only_for_gender`.
4. ✅ **CONFERMATA.** Directus+GraphQL espandono le relazioni in base ai permessi del ruolo: un
   utente vede la relazione estesa dove l'SDL pubblico mostra solo l'id. Comportamento stabile.
   Cautela: non confondere `user_details` con `user_details_aggregated_count` (valori aggregati).

### ✅ DECISO (2026-06-19) — un unico endpoint REST `GET /path/me/progress`

Invece di GraphQL per 3 aree + REST per integrazione, Daniele crea **un solo endpoint REST** che
ritorna tutto il progresso già calcolato.

> ⚠️ **Endpoint reale (confermato dal backend, 2026-06-22):** `GET /path/me/progress`
> (bearer token), **non** `/path/progress`. Lo shape è invariato rispetto a quanto concordato.

**Shape CONCORDATA** (proposta da Daniele, confermata dal client):
```
GET /path/me/progress    (bearer token)
{
  "data": {
    "overall": { "completed": 23, "total": 132, "percent": 17 },
    "areas": {
      "allenamento":   { "completed": 8, "total": 44, "percent": 18 },
      "alimentazione": { "completed": 6, "total": 44, "percent": 14 },
      "benessere":     { "completed": 5, "total": 44, "percent": 11 },
      "integrazione":  { "completed": 4, "total": 0,  "percent": 0  }
    }
  }
}
```
Decisioni sulle due domande di Daniele:
- **`areas` come OGGETTO** (chiave = `root.internal_name`), non array. Le 4 aree sono fisse e
  note → mapping 1:1 esplicito, nessuna ambiguità d'ordine. ✅
- **`percent`**: tecnicamente ridondante (il client lo calcola da `completed/total`), ma **ok
  tenerlo** — evita discrepanze di arrotondamento UI. Il client può ignorarlo se preferisce
  ricalcolarlo. Intero 0-100.

✅ **Risolto:** i valori erano inventati. Deciso che il backend **invia sempre tutte e 4 le
aree**, anche `integrazione` con `total: 0` (utente senza kit) — NON la omette. Motivo: le card
sono fisse nel layout, ometterne una squilibra la griglia. Il client gestisce già `total == 0`
(`PathData.progress` → 0).

`area` = `root.internal_name`. Un solo meccanismo, zero logica di dominio nel client,
**copre anche [[statistics-implementation-plan|Statistiche]]** (stesso dato per area).
→ La sezione §2 (calcolo GraphQL) diventa **riferimento storico**: la fa il backend.

## Stato

- **2026-06-22** — ✅ **INTEGRATO.** Endpoint reale `GET /path/me/progress` confermato dal
  backend e cablato nel client:
  1. DTO `PathProgressResponseDto`/`PathProgressDto`/`AreaProgressDto` (data.overall +
     data.areas come `Map<String,AreaProgressDto>`, json_serializable).
  2. `PathRepositoryImpl` riscritto su `Dio` (NON GraphQL): `GET /path/me/progress`, error-map
     `ApiException.fromDio`. `path_mock_data_factory.dart` **eliminato**.
  3. `PathCubit` invariato. `fetchPath(l10n)` mantiene `l10n` perché titoli/asset/header
     restano **client-side** (mapping per chiave `internal_name`: `allenamento`,
     `alimentazione`, `benessere`, `integrazione`).
  4. DI: `PathRepositoryImpl(dio: getIt())`.
  - Stesso endpoint riusabile da [[statistics-implementation-plan|Statistiche]].
  - Aperti: scope `overall` (Francesco Galatro); `integrazione.total: 0` gestito client-side
    (`total == 0 → progress 0`).
- **2026-06-19** — Shape concordata con Daniele (areas=oggetto, percent incluso).

> §2/§3 (calcolo e query GraphQL) restano come **riferimento storico** — la logica è lato
> backend. Il client legge un JSON piatto.

## Dettaglio area — probe backend (2026-06-22)

Probe col token reale (ruolo app, `app_access: false`) su staging, prima di costruire la
schermata di dettaglio (lista step al tap su una card). Stato: **bloccato su 2 domande**.

### Cosa funziona ✅
- `POST /path/steps/{id}/start` → **200**, crea l'`user_activities` (verificato: scrive davvero).
- `/items/percorsi_groups` leggibile: `is_percorso_main_tab`, `icon`, `tools`, `translations`,
  `steps[]` (junction `percorsi_content_id` + `sort`).
- `/items/percorsi_groups_translations` → titoli gruppo ("Allenamento", "Materiali", …).
- `/items/percorsi_content` → titolo, asset, content_blocks, timeframe.
- `user_activities` = modello reale del "completato": `completed_on` + `activity[]` M2A che punta
  a `percorsi_content` via `collection` + `item`.

### Cosa è rotto / bloccato ⚠️
- `percorsi` + campo **`root`** → **INTERNAL_SERVER_ERROR** (sia GraphQL che REST). La relazione
  `root.internal_name` che mappa group→area **non è accessibile** col ruolo app.
- `GET /items/percorsi/{id}` → **FORBIDDEN**. Il group espone solo `percorso: <id>` (es. 8, 26),
  ma quell'id non è risolvibile.
- Nessun endpoint REST aggregato per il dettaglio (`/path/me`, `/path/me/detail`, `/path` → 404).
- `POST /path/steps/{id}/complete` con body `{}` → **400** (manca lo shape del payload).

### Domande aperte al backend (Daniele)
1. **group → area:** come capisce il client quali `percorsi_groups` sono di una certa area
   (allenamento/alimentazione/benessere/integrazione), visto che `percorsi.root` è in 500 e
   `/items/percorsi/{id}` è 403? Opzioni: (a) campo `area`/`internal_name` leggibile sul group;
   (b) sbloccare `percorsi.root.internal_name` per il ruolo app; (c) **preferito** — endpoint
   REST di dettaglio tipo `/path/me/progress` che torna gli step dell'area già con stato
   fatto/non fatto.
2. **complete:** qual è il body corretto di `POST /path/steps/{id}/complete`? (`start` torna 200
   con body vuoto, `complete` dà 400.)

→ Senza (1) non si costruisce la lista del dettaglio; senza (2) non si cabla il "completa step".

### Risposte Daniele (2026-06-22) → entrambe risolte

**2. `complete` — RISOLTA.** Body:
```json
{ "percorsoInternalName": "allenamento" | "alimentazione" | "benessere" }
```

**1. group → area — RISOLTA via endpoint REST di dettaglio (opzione c).** Daniele sta sistemando
i permessi di `percorsi.root`, ma in parallelo fornisce un endpoint dettaglio dedicato.

> ✅ **URL definitivo (confermato dal backend):** `GET /path/me/areas/{area}/steps` (bearer token).
> `{area}` = chiave area pulita (`allenamento`/`alimentazione`/`benessere`/`integrazione`). Ritorna
> tutto già pronto (groups + steps con stato fatto/non fatto).

#### Shape REALE — VERIFICATO su staging col token reale (2026-06-23)

Probe `GET /path/me/areas/allenamento/steps` → **200**. Sample completo salvato in
[`wiki/samples/path-area-steps-allenamento.json`](samples/path-area-steps-allenamento.json).
Struttura reale (più ricca di quella proposta — ci sono `current_step_id` + `active_timeframe`
top-level e gli step hanno già `asset`/`is_current`/`locked`):
```jsonc
{
  "data": {
    "area": "allenamento",
    "percorso": { "id": "27", "internal_name": "allenamento~tipo-4-m~m", "has_progressive_steps": true },
    "progress": { "completed": 5, "total": 27, "percent": 19 },
    "current_step_id": 95,                       // = lo step con is_current:true (no doppia lettura user_details)
    "active_timeframe": { "id": 3, "sort": 3 },
    "groups": [
      {
        "id": "42", "sort": 1,
        "is_percorso_main_tab": true,            // group "tab principale" (gli step veri)
        "show_limited_steps_value": 2,
        "icon": { "id": "<file-uuid>", "type": "image/svg+xml", ... },
        "tools": ["timer", "reminder"],
        "categories": [...],
        "translations": [{ "languages_code": "it-IT", "title": "Allenamento" }],
        "steps": [
          {
            "id": "1", "sort": 1,
            "timeframe": { "id": 1, "sort": 1, "translations": [{ "languages_code": "it-IT", "title": "1° mese" }] },
            "translations": [{ "languages_code": "it-IT", "title": "settimana 1 - allenamento 1" }],
            "asset": {
              "asset_is_video": true,
              "vimeo_url": "https://vimeo.com/1120185037",
              "default_asset": null, "mobile_asset": null, "mobile_resolution": "md",
              "video": null, "translations": []
            },
            "started": true, "completed": true,
            "started_on": "2025-10-17T15:14:41", "completed_on": "2026-03-02T17:02:41",
            "is_current": false, "locked": false
          }
          // ... 27 step in totale
        ]
      },
      { "id": "43", "sort": 2, "is_percorso_main_tab": false, "translations": [{ "title": "Materiali" }], "steps": [] }
    ]
  }
}
```

**Fatti reali dal sample (allenamento, utente ca0d6833…):**
- **2 group**, NON i "mesi": `Allenamento` (`is_percorso_main_tab:true`, 27 step) e `Materiali`
  (`false`, 0 step). → la lista a "mesi" del Figma **NON è data dai group**.
- **Le righe "1°/2°/3° mese" del Figma = i `timeframe`** degli step del group principale. Conteggi
  reali: `1° mese` 5/9, `2° mese` 0/10, `3° mese` 0/8. Titolo riga = `timeframe.translations.title`.
  → **lista = raggruppare `groups[is_percorso_main_tab].steps[]` per `step.timeframe.id`**, % per gruppo.
- Tutti i campi extra richiesti **ci sono**: `asset`, `is_current`, `locked`, `started/completed`+date.
- `is_current` (1 solo step, id 95) **combacia** con `current_step_id` top-level → niente più lettura
  da `percorso_<area>_curr_step` in `user_details`.
- ⚠️ **`asset` è video-oriented**: ha `asset_is_video`, `vimeo_url`, `default_asset`, `mobile_asset`,
  `mobile_resolution`, `video`. Nel dataset allenamento **tutti e 27 hanno `vimeo_url`** e 0 hanno
  `default_asset`/`mobile_asset`. → l'"immagine grande" del Figma per allenamento è un **video Vimeo**;
  il DTO deve gestire sia asset immagine (`default_asset`/`mobile_asset`) sia video (`vimeo_url`/`video`).
- `group` ha anche `icon`, `tools` (`["timer","reminder"]`), `categories`, `show_limited_steps_value`.
- ⚠️ **NULLABILITÀ (bug trovato in run reale 2026-06-23):** il group `Materiali`
  (`is_percorso_main_tab:false`) ha **`tools: null`**, `show_limited_steps_value` può essere assente,
  e `categories` può contenere oggetti complessi o essere null. → nel DTO `tools`,
  `showLimitedStepsValue`, `categories`, `icon` DEVONO essere **nullable**, altrimenti
  `json_serializable` lancia `as List<dynamic>` su null e la UI mostra "qualcosa è andato storto".
  Tutti gli `id` (percorso/group/step/current_step_id) sono **stringhe** nel JSON HTTP; solo
  `timeframe.id`/`active_timeframe.id` sono int.

> ✅ **Tutto verificato. Niente più incognite di shape.** **Prossimo passo:** scaffold DTO
> (`PathAreaStepsDto` + nested) + schermata dettaglio (secondo PR): lista = step raggruppati per
> `timeframe`, tap step → contenuto (asset video/immagine + title + content). Cablare `complete`
> con body `{"percorsoInternalName": "<area>"}`.

#### Convenzione LOCK / stato attivo — RISPOSTA backend (2026-06-23)

Il backend ha confermato dove leggere lock e stato attivo (risolve il punto 2 di
[`messaggio-daniele-path-dettaglio.md`](messaggio-daniele-path-dettaglio.md)):

| Concetto | Campo autoritativo |
|---|---|
| Lucchetto sul **mese** | `timeframes[].locked` |
| Mese **attivo** | `timeframes[].is_current` |
| Lucchetto sullo **step** | `step.locked` |
| Step **attivo** | `step.is_current` |
| **Area intera** bloccata | `access.percorso_locked` |

⚠️ **Discrepanza con il sample del 2026-06-23:** nel sample reale di staging questi nuovi
contenitori (`timeframes[]` top-level + blocco `access`) **non esistono ancora** — c'è solo
`step.timeframe` annidato e `step.locked`/`step.is_current` (tutti `false` nei dati reali). La
risposta del backend descrive lo shape **futuro**. Cablato lato client in modo tollerante:
- DTO: `PathAccessDto.percorsoLocked` (`access.percorso_locked`), `PathAreaStepsDto.timeframes`
  (top-level, nullable), `PathTimeframeDto.locked`/`isCurrent` (nullable). Reggono sia il vecchio
  sia il nuovo shape.
- `PathRepositoryImpl._mapAreaStepsDto`: legge lock/active del mese dal top-level `timeframes[]`
  quando presente, altrimenti fallback al `step.timeframe` annidato; `PathAreaDetail.isLocked`
  da `access.percorso_locked`. Domain: `PathTimeframeGroup.isLocked`/`isCurrent`,
  `PathAreaDetail.isLocked`.
- **Da verificare su staging quando il backend pubblica il nuovo shape:** che `timeframes[]` e
  `access` arrivino popolati; la Ui del lucchetto mese/step e dell'area bloccata.

### Mappatura UI dal Figma del dettaglio (2026-06-23)

Figma del dettaglio area (`Screenshot 2026-06-23`, es. "Allenamento"). Due schermate:

**Lista (PAGINA AREA):**
- Header back + titolo area con icona.
- **Card riepilogo area** in alto: icona, label area, barra progresso `22/60` + `70% completato`
  → dato = **`data.progress`** dell'endpoint `GET /path/me/areas/{area}/steps` (NON `/path/me/progress`).
- Lista di righe con: **badge % a sinistra** (es. 25%, 0%), **titolo** ("1° mese", "2° mese",
  "3° mese", + "Materiali"), **chevron `>`**.
  - ✅ **RISOLTO sui dati reali (2026-06-23): ogni riga = un `timeframe`**, NON un group. Si
    raggruppano gli `steps[]` del group `is_percorso_main_tab:true` per `step.timeframe.id`;
    titolo riga = `timeframe.translations.title` (es. "1° mese"); % = step completati/totali del
    timeframe. (Verificato: allenamento ha 3 timeframe — 5/9, 0/10, 0/8.) Il group `Materiali`
    (`is_percorso_main_tab:false`, 0 step) è un'eventuale sezione a parte, non un "mese".

### Stringhe localizzabili sotto `translations` — DECISO: lasciate nidificate (2026-06-23)

Le stringhe localizzabili stanno quasi sempre dentro `translations` (formato nativo Directus per il
multilingua). Il backend si è offerto di **imploderle** (appiattirle inline) visto che oggi c'è una
sola lingua. **Deciso: lasciarle sotto `translations`** (nessuna implosione lato backend). Motivi:
- È il formato nativo Directus; imploderle sarebbe una trasformazione custom che può divergere tra
  endpoint e va mantenuta.
- L'app supporta già i18n (default `it`, fallback `en`) → con `translations` il contratto non cambia
  quando si aggiunge una seconda lingua; con l'implosione si dovrebbe tornare indietro.
- Costo client banale e **pattern già consolidato**: `home_repository_impl.dart` legge i `curr_step`
  con `translations { title }`. Nel DTO si prende il primo elemento (o quello che matcha
  `languages_code`).

### ⚠️ TRABOCCHETTO nomenclatura — tre concetti simili, NON intercambiabili

Il backend usa nomi quasi identici per cose diverse. Da tenere bene a mente nel mapping DTO:

| Dove | Campo | Esempio valore | Cos'è |
|------|-------|----------------|-------|
| body di `POST .../complete` | `percorsoInternalName` (camelCase) | `"allenamento"` | **chiave area "pulita"**, una delle 3 root a step |
| `/path/me/progress` → `data.areas` | chiave dell'oggetto | `"allenamento"` | stessa chiave area pulita (= `root.internal_name` concettuale) |
| dettaglio area → `data.percorso.internal_name` | `internal_name` (snake_case) | `"allenamento~tipo-4-m~m"` (valore reale dal sample) | **identificativo del percorso fisico** (con suffissi variante/gender), ≠ chiave area |

→ Il valore da mandare a `complete` è la **chiave area** (`allenamento`/`alimentazione`/`benessere`),
**non** il `percorso.internal_name` con i tilde. Non confonderli in fase di mapping: stesso prefisso,
semantica diversa. (Confermato nel thread con Daniele, 2026-06-22 — lui stesso ha riconosciuto
l'incoerenza: `internalName` da una parte, `area` dall'altra, `internal_name` ancora un'altra cosa.)

## PR 2 — Dettaglio area: piano operativo (2026-06-23)

Secondo PR: schermata di **dettaglio area** (tap su una card del percorso → lista step di
quell'area, poi tap su step → contenuto). Contratto API già **verificato sui dati reali** (vedi
shape sopra + `wiki/samples/path-area-steps-allenamento.json`). Niente più incognite: si scrive.

### Modello dati (lista = step raggruppati per `timeframe`)
- L'endpoint torna `groups[]`, ma la UI raggruppa per **timeframe**. Il client prende il group con
  `is_percorso_main_tab == true`, poi raggruppa i suoi `steps[]` per `step.timeframe.id` (ordinati
  per `timeframe.sort`, e gli step per `sort`). Ogni gruppo-timeframe → una riga (titolo
  `timeframe.translations.title`, % = completati/totali del timeframe).
- Il group `Materiali` (`is_percorso_main_tab:false`) è un'eventuale sezione separata, non un "mese".

### Data
- `data/dto/path_area_steps_dto.dart` (+ `.g.dart`) — `json_serializable`, come `path_progress_dto`.
  Nested: `PathAreaStepsResponseDto{ data }` → `PathAreaStepsDto{ area, percorso, progress,
  currentStepId, activeTimeframe, groups }`; `PathPercorsoDto{ id, internalName, hasProgressiveSteps }`;
  `PathGroupDto{ id, sort, isPercorsoMainTab, showLimitedStepsValue, icon, tools, translations, steps }`;
  `PathStepDto{ id, sort, timeframe, translations, asset, started, completed, startedOn, completedOn,
  isCurrent, locked }`; `PathTimeframeDto{ id, sort, translations }`; `PathStepAssetDto{ assetIsVideo,
  vimeoUrl, defaultAsset, mobileAsset, mobileResolution, video, translations }`.
  - **translations** nidificate → helper che prende il primo elemento (o match `languages_code`),
    come già si fa per i `curr_step` in `home_repository_impl.dart`.
  - **`@JsonKey(name: 'internal_name')`** ecc. per i campi snake_case.
- `domain/entities/path_area_detail.dart` — entità pulite per la UI: `PathAreaDetail{ area, percorso,
  completed, total, currentStepId, timeframeGroups: List<PathTimeframeGroup> }`;
  `PathTimeframeGroup{ timeframeId, title, completed, total, steps }`;
  `PathStepItem{ id, title, timeframeTitle, asset (PathStepMedia), isCompleted, isStarted, isCurrent,
  isLocked }`; `PathStepMedia{ isVideo, vimeoUrl, imageUrl }` (imageUrl da `default_asset`/`mobile_asset`
  via `${Env.baseUrl}/assets/...`, come `home_repository_impl.dart:177`).
- `domain/path_repository.dart` — aggiungere
  `Future<PathAreaDetail> fetchAreaSteps({required String area, required AppLocalizations l10n})`
  e cablare davvero `Future<void> completeStep({required String stepId, required String area})`
  (oggi stub). `startStep` già verificato (200).
- `data/path_repository_impl.dart` — `GET /path/me/areas/$area/steps`, mapping DTO→entità con il
  raggruppamento per timeframe; `POST /path/steps/$stepId/complete` body
  `{"percorsoInternalName": area}`; `POST /path/steps/$stepId/start`. Error-map `ApiException.fromDio`.

### Presentation
- `presentation/cubit/path_detail_cubit.dart` (+ `path_detail_state.dart`) — carica `fetchAreaSteps`,
  espone `completeStep`/`startStep` con ricarica ottimistica. Stati initial/loading/loaded/error
  come `PathCubit`.
- `presentation/path_area_detail_screen.dart` — `AppHeader` (titolo area) + card riepilogo
  (`progress`) + lista per timeframe (riga = titolo timeframe + % + chevron → espande/naviga agli step).
- `presentation/path_step_screen.dart` — contenuto step: media in cima (immagine **o** player Vimeo
  se `asset.isVideo`), titolo, corpo. Pulsante "completa" → `completeStep`.
- Widget: `widgets/path_timeframe_row.dart`, `widgets/path_step_tile.dart` (badge stato
  done/current/locked da `isCurrent`/`locked`/`completed`).
- Navigazione: rotta `path/:area` (e `path/:area/step/:stepId`) in GoRouter; tap sulla card area in
  `path_screen.dart` naviga passando `PathArea.id` (= chiave area pulita).

### DI
- `lib/app/di.dart` — registrare `PathDetailCubit` (factory) iniettando `PathRepository`
  (+ `UserCubit` se serve `myId`; ma l'endpoint è `/me`, quindi probabilmente non serve).

### l10n
- Nuove stringhe IT/EN: titolo schermata dettaglio, label "completa step", stato bloccato, ecc.
  (template EN, default IT — vedi convenzione i18n del progetto).

### Verifica
1. `dart analyze` + `dart format` (agent `dart-linter`).
2. Run manuale: aprire allenamento → 3 righe "1°/2°/3° mese" con % 56/0/0, step con video Vimeo,
   step `is_current` (id 95) evidenziato.
3. `POST .../complete` su uno step non completato → 200, progress si aggiorna.

> ⚠️ **Vimeo:** allenamento ha solo `vimeo_url` (0 immagini). Serve decidere il player (es.
> `webview`/embed Vimeo) — possibile dipendenza nuova in `pubspec.yaml`. Altre aree potrebbero usare
> `default_asset`/`mobile_asset` (immagini): verificare con un probe su `alimentazione`/`benessere`
> prima di assumere "tutto video".

## Related
- [[percorso-read]]
- [[percorso]]
- [[contradictions]]
- [[home-implementation-plan]]
- [[graphql]]
