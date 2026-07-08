# Diario personale — Analisi API (task #7)

**Data:** 2026-07-03
**Fonte:** OpenAPI "Kilocal App" + **introspection GraphQL autenticata e prove REST end-to-end su staging**
**Riferimento task:** `docs/stato-avanzamento-2026-07-03.md` riga 25 — *"Diario personale dell'utente 🟡 — Schermata Diario presente lato UI; manca il collegamento alle API"*

## ⚠️ Correzioni verificate su staging (contratti reali, non solo Swagger)

Testando con token reale, alcune assunzioni iniziali basate solo sullo Swagger erano imprecise:

1. **`user_activities.activity.item` è una UNION tipizzata** (`articles | percorsi_content | percorsi_materials`), **non** una stringa-id. Va selezionata con inline fragment `item { ... on percorsi_content { ... } }`. Titolo step + area si leggono **inline** (`translations.title` e `used_in[].percorsi_groups_id.percorso.root.internal_name`) — nessuna seconda query.
2. **Il filtro annidato** `activity.collection._eq` sull'M2A **non funziona** da autenticato (torna 0 righe): filtrare solo `completed_on _nnull` server-side e scartare client-side gli item non-`percorsi_content`.
3. **I cataloghi `goal_categories` e `goals` SONO esposti via GraphQL** (autenticato). `goal_categories`: id 3=Benessere, 4=Attività esterne, 5=Fashion. Quindi **niente placeholder**: il picker categoria usa dati reali. Un `category` id inesistente (es. `1`) → **500** "Invalid foreign key".
4. **`POST /journal/goals` ritorna solo l'id** (`{"data": 614}`), **non** l'oggetto goal completo come dichiarato nello Swagger. Il goal creato va ricostruito lato client dall'input.
5. **PATCH** → `{"data":"<id>"}`, **DELETE** → `204`. `GET` restituisce `id` come **intero** e `category` come intero (gestiti con converter tolleranti).

## TL;DR

Le API **esistono già**, contrariamente a quanto riportato nel task ("persistenza backend da definire").
Il Diario nel backend è modellato come **due domini distinti**:

| Sezione Diario | Dato | Lettura | Scrittura |
|----------------|------|---------|-----------|
| **Attività (cronologia)** | `user_activities` (step completati) | GraphQL (`POST /graphql`) — sola lettura | — (nessuna scrittura: gli step si completano da `/path/steps/*`) |
| **Traguardi / obiettivi** | `user_reminders` con `category`/`related_goal` | `GET /journal/goals` | `POST` / `PATCH` / `DELETE /journal/goals` |

La schermata attuale (`lib/features/diary/`) mostra **6 card mock hardcoded** ("Attività giorno N") senza alcuna chiamata di rete. Va decisa quale delle due sezioni (o entrambe) la UI deve rappresentare — vedi §5.

---

## 1. Stato attuale del codice

- `lib/features/diary/presentation/diary_screen.dart` — `ListView.builder` con `itemCount: 6` fisso, dati inventati (`'Attività giorno ${index+1}'`, `isCompleted = index % 2 == 0`).
- `lib/features/diary/presentation/widgets/diary_entry_card.dart` — card presentazionale (title/subtitle/isCompleted), `onTap: () {}` vuoto.
- **Nessun** layer `data/` né `domain/`, nessun cubit, nessun repository, nessuna DI registrata. È solo UI.

---

## 2. API disponibili — Diario Attività (cronologia)

Sola lettura via GraphQL. Collection: `user_activities`.

**Vista raggruppata per giorno** (`user_activities_aggregated`):
```graphql
# groupBy: ["year(started_on)", "month(started_on)", "day(started_on)"]
```

**Dettaglio giorno** — filtro tipico step completati:
```json
{
  "filter": {
    "_and": [
      { "completed_on": { "_nnull": true } },
      { "activity": { "collection": { "_eq": "percorsi_content" } } }
    ]
  }
}
```

Schema `UserActivity`:
| Campo | Tipo | Note |
|-------|------|------|
| `id` | uuid | |
| `started_on` | date-time, nullable | |
| `completed_on` | date-time, nullable | `!= null` ⇒ attività completata |

> ⚠️ Le attività **non si scrivono dal Diario**: vengono create/completate dai percorsi tramite
> `POST /path/steps/{stepId}/start` e `POST /path/steps/{stepId}/complete`. Il Diario le **legge** soltanto.

---

## 3. API disponibili — Diario Traguardi (`/journal/goals`)

REST completo, tag OpenAPI **`Diario`**. Sono `user_reminders` con `category` **oppure** `related_goal`
(i promemoria calendario "puri" stanno invece su `/tools/reminders`).

Tutti gli endpoint richiedono `bearerAuth` (access token da `POST /auth/login`).

| Metodo | Path | operationId | Descrizione |
|--------|------|-------------|-------------|
| GET | `/journal/goals` | `diarioGoalsList` | Lista traguardi utente → `{ data: UserGoal[] }` |
| POST | `/journal/goals` | `diarioGoalsCreate` | Crea traguardo (body `UserGoalInput`) → `{ data: UserGoal }` |
| PATCH | `/journal/goals/{id}` | `diarioGoalsUpdate` | Aggiorna (id uuid, body `UserGoalInput`) |
| DELETE | `/journal/goals/{id}` | `diarioGoalsDelete` | Elimina (id uuid) → `204` |

### Schema `UserGoal` (= `UserReminder` + campi diario)
| Campo | Tipo | Note |
|-------|------|------|
| `id` | uuid | |
| `content` | string, nullable | testo del traguardo |
| `due_date` | date, nullable | |
| `due_time` | string, nullable | |
| `completed_at` | date-time, nullable | `!= null` ⇒ traguardo completato |
| `redirectTo` | string, nullable | deep-link opzionale |
| `category` | int \| string, nullable | categoria personale (`goal_categories`) |
| `related_goal` | int \| string, nullable | traguardo predefinito da catalogo `goals` |

### Schema `UserGoalInput` (create/update)
| Campo | Tipo | Note |
|-------|------|------|
| `content` | string | |
| `due_date` | date | |
| `due_time` | string | |
| `completed_at` | date-time, nullable | |
| `redirectTo` | string | |
| `category` | int \| string | **obbligatorio** per obiettivi personali (se `related_goal` assente) |
| `related_goal` | int \| string | alternativa a `category` (collega al catalogo `goals`) |

**Regola:** un goal deve avere **o** `category` **o** `related_goal`. Per marcare completato → `PATCH` con `completed_at`.

### Errori
`401` Unauthorized (token mancante/non valido) · `403` Forbidden (ruolo non User) · `400` BadRequest · `404` (solo su PATCH, traguardo non trovato).

---

## 4. Cosa manca lato app (gap da implementare)

Nessuna API mancante lato backend. I gap sono **tutti applicativi**:

1. **Layer data/domain/presentation** per la feature `diary` (attualmente assenti). Seguire Clean Architecture del progetto.
2. **Retrofit client** per `/journal/goals` (GET/POST/PATCH/DELETE) — via `api-integrator`, interceptor Dio + bearer già esistenti.
3. **DTO + mapper** `UserGoal` / `UserGoalInput`.
4. **Query GraphQL** per `user_activities` (aggregata per giorno + dettaglio) se si vuole la cronologia attività.
5. **Cubit** `DiaryCubit` (load / create / update / delete / toggle-complete) — via `bloc-author`.
6. **DI** get_it + rotta GoRouter già presente (schermata esiste).
7. Sostituire le **6 card mock** con dati reali.

### Punti da chiarire con il prodotto/backend (non bloccanti sull'API)
- **`category` e `related_goal` sono ID numerici/uuid**: servono le collection cataloghi `goal_categories` e `goals` per popolare la UI di creazione traguardo. Verificare se esposti via GraphQL (non presenti in questa spec — controllare `/server/specs/oas` Directus).
- Formato `due_time` non specificato (string libera vs `HH:mm`) — da verificare con un esempio reale.

---

## 5. Decisione UI aperta

La schermata attuale mostra un elenco generico "Attività giorno N / completata|in attesa". Va deciso se il Diario rappresenta:
- **(a)** la *cronologia attività* (`user_activities`, read-only da GraphQL), oppure
- **(b)** i *traguardi personali* (`/journal/goals`, CRUD completo), oppure
- **(c)** entrambe (es. tab / sezioni), come suggerisce la modellazione backend.

Il tag `Diario` in OpenAPI copre esplicitamente i **traguardi**; la cronologia attività è documentata come sezione GraphQL separata dello stesso dominio "Diario".

---

## Riferimenti spec

- OpenAPI Kilocal App: `/api/docs/openapi.yaml`
- Directus REST (cataloghi): `/server/specs/oas`
- GraphQL SDL: `/server/specs/graphql/system`
- Tabella "Riepilogo domini" nella spec: righe *Diario attività* (`user_activities`) e *Diario traguardi* (`user_reminders` → `/journal/goals`).
