# Statistics — implementation plan (mock → dynamic)

> **Aggiornato 2026-06-19.** Piano per dinamicizzare la schermata `statistics`, verificato contro
> lo **Swagger/SDL reale** dello staging (`https://cms-stg.kilocal.thefullproject.it`). Lo Swagger
> ha priorità assoluta sul wiki. Vedi [[diario-attivita]], [[graphql]].

## 0. Verifica API (cosa esiste DAVVERO)

Sorgenti controllate il 2026-06-19 (SDL pubblico `GET /server/specs/graphql`):

| Elemento | Verificato | Esito |
|----------|-----------|-------|
| `user_activities_aggregated` | SDL | ✅ esiste (`groupBy`, `countAll`, `count`, ...) |
| `user_activities_aggregated.count.{id,completed_on,started_on}` | SDL → `Int` | ✅ esiste |
| `user_activities` (`id/started_on/completed_on/activity`) | SDL | ✅ esiste |
| `user_activities.activity[].item` (M2A polimorfico → `percorsi_content`) | SDL | ✅ esiste |
| `user_details.active_timeframe` | SDL → `Int` | ✅ esiste (mese/timeframe corrente) |
| `percorsi_content` / root `internal_name` | **assente** dall'SDL pubblico | ⚠️ auth-gated |

### Conseguenze (verità operativa)

1. **L'aggregato NON espone direttamente l'area.** `user_activities_aggregated.count` raggruppa
   per i campi propri di `user_activities` (date, id), **non** per la root del percorso. Per
   ottenere "completati **per area**" bisogna passare dalla relazione M2A `activity.item →
   percorsi_content → root.internal_name`, esattamente come fa `home_repository_impl.dart:99`
   (che filtra/raggruppa lato client iterando le activities). → **stesso pattern della home.**
2. **`percorsi_content`/root sono auth-gated** (assenti dall'SDL pubblico) ma la **home già li
   usa con successo** → il token li sblocca. Questa è la prova che la query regge.
3. **Il "totale" per area** (denominatore) è lo stesso problema di `path` (vedi
   [[path-implementation-plan]] §5, domanda 1). → Riusare la **stessa fonte** di `path`/`home`
   (`percorsi_content_aggregated` per timeframe). Se quella query è ancora in attesa di conferma
   backend, lo è anche qui: **dipendenza condivisa con path**.

## 1. Scope

**IN scope:**
- Lista `AreaStat` reale: per le 3 root a step (`allenamento`/`alimentazione`/`benessere`)
  `completed/total` del timeframe selezionato; `integrazione` a fasi.
- Selettore mese/timeframe (icona calendario già presente in `statistics_screen.dart:42`,
  oggi `onPressed: () {}`) → default `active_timeframe`.

**FUORI scope (rinviato):**
- Grafici storici multi-mese (richiede `groupBy` su date — fattibile ma non nel primo giro).

## 2. Calcolo (riuso pattern home)

Per il timeframe selezionato `T`:
- **completed per area** = `user_activities` con `completed_on _nnull`, la cui `activity.item`
  (`percorsi_content`) ha `timeframe.sort == T` e `root.internal_name == <area>`. Conteggio
  lato client (come home), oppure `user_activities_aggregated` con `groupBy` se il backend
  conferma il group per relazione.
- **total per area** = `percorsi_content_aggregated` filtrato per `root` + `timeframe.sort == T`.
- **integrazione** = progresso a fasi da `percorso_integrazione_curr_phase` (vedi
  [[path-implementation-plan]] §2).

## 3. Modifiche file

### Domain (nuovo — la feature oggi non ha data/domain layer)
- `domain/entities/area_stat.dart` — invariato (già adeguato: `area/month/completed/total`).
- `domain/statistics_repository.dart` (nuovo) —
  `Future<List<AreaStat>> fetchStatistics({required String myId, required int timeframe, required AppLocalizations l10n})`.

### Data (nuovo)
- `data/dto/area_stat_dto.dart` (+ `.g.dart`) — `json_serializable`.
- `data/statistics_repository_impl.dart` (nuovo) — su `GraphqlClient`; riuso schema aggregati
  di `home_repository_impl.dart`; error-mapping `ApiException.fromDio`.

### Presentation
- `presentation/cubit/statistics_cubit.dart` — iniettare `StatisticsRepository` + `UserCubit`
  (per `myId` e `active_timeframe`), come `HomeCubit`/`PathCubit`. Mantenere `loadWithData` per
  i test; `load()` chiama il repository. Aggiungere `selectTimeframe(int)`.
- `presentation/statistics_screen.dart:19,23` — `getIt<StatisticsCubit>()..load()`; rimuovere
  `MockDataFactory.statistics`. Cablare l'icona calendario (`:42`) al selettore timeframe.

### DI
- `lib/app/di.dart` — registrare `StatisticsRepository` (lazySingleton) e `StatisticsCubit`
  (factory con `userCubit`), sul modello delle sezioni Home/Path.

### Cleanup
- Rimuovere `MockDataFactory.statistics` da `lib/core/utils/mock_data_factory.dart` (verificare
  che non sia usato altrove prima di eliminare).

## 4. Verifica
1. `dart analyze` + `dart format` (agent `dart-linter`).
2. Run manuale: i numeri per area devono **concordare** con la home sullo stesso timeframe.
3. Test cubit: `loadWithData` + stato loaded.

## 5. Dipendenze / rischi
- **Condivisa con [[path-implementation-plan]]:** il "totale per area" usa la **stessa mappa
  `stepId → area`** ora confermata dal backend (`percorsi { root, groups, steps }`, vedi
  path §2). **Non più bloccante.** → Implementare path + statistics insieme riusando un'unica
  sorgente per la mappa area/totali.
- `integrazione` nelle statistiche eredita la stessa complessità di path (kit + took_dates) →
  stessa decisione: preferire l'endpoint REST dedicato se Daniele lo crea.

## Stato
- **2026-06-19** — Backend ha risposto (vedi path §5): totale per area risolto via mappa
  `stepId→area`. **Sbloccato.** Prossimo passo: implementare insieme a path via `api-integrator`,
  riusando la mappa per le 3 root a step. `integrazione` quando arriva l'endpoint REST.
- **2026-08-11** — Fix: `integrazione` sotto filtro mese non eredita più il valore lifetime.
  Selezionando mese 2/3 la card mostrava una percentuale "sporca" (il progresso complessivo)
  anche per mesi non ancora sbloccati. Ora `StatisticsRepositoryImpl._fetchPhaseCounts`
  risolve l'area a fasi tramite `IntegrazioneRepository` (riuso, nessuna query duplicata):
  - **mese N → fase con `sort == N`** (il piano integratori avanza una fase per mese);
  - fase **non ancora sbloccata** (`IntegrazioneData.isPhaseLocked`) → **`0/0`**;
  - fase sbloccata → `total` = somma dei `durationDays` dei prodotti della fase,
    `completed` = giorni presi (`took_dates`), *clampati* per prodotto così un integratore
    loggato oltre la durata non porta la barra sopra il 100%;
  - nessun `myId` / nessun kit / errore GraphQL → fallback al lifetime (best-effort: le altre
    aree restano visibili).
  La label della card non è più forzata a "Fase 1": sotto filtro tutte le aree mostrano il mese
  selezionato. `StatisticsCubit` riceve `UserCubit` per passare `myId`.

## Related
- [[diario-attivita]]
- [[path-implementation-plan]]
- [[home-implementation-plan]]
- [[graphql]]
