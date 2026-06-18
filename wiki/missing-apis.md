# API mancanti → RISOLTE

> **Aggiornato 2026-06-18.** Questa pagina elencava endpoint **proposti da confermare** per
> alimentare le schermate Figma, perché la wiki documentava solo lo shop e-commerce. Lo
> **Swagger dell'app mobile** (`/api/docs`, tab *Kilocal App*) è ora arrivato: **quasi tutti
> esistono davvero**, a path diversi. Sotto, la mappatura proposta → endpoint reale. Le note
> originali restano in fondo come storico.

## Mappatura: proposto → reale

| Area | Proposto (vecchio) | Reale (Swagger app) | Pagina |
|------|--------------------|---------------------|--------|
| Survey domande | `GET /api/survey/{type}` | GraphQL `surveys`/`survey_sections`/`survey_question` | [[survey]] |
| Survey invio | `POST /api/survey/{type}/answers` | `POST /survey/submit/{internalName}` | [[survey]] |
| Prova d'acquisto | `POST /api/proof-of-purchase` | barcode check **client-side** su `products` | [[integrazione]] |
| Stato programma | `GET /api/program/status` | GraphQL `percorsi` + `user_details` | [[percorso-read]] |
| Home hero | `GET /api/home/hero` | GraphQL (contenuti CMS) | [[graphql]] |
| Abilitazioni hub (§2bis) | `GET /api/me/entitlements` | `user_details.profile_status` + filtri CMS server | [[authentication]] |
| Percorso struttura | `GET /api/path`, `/api/path/{hub}` | GraphQL `percorsi`/`percorsi_groups`/`percorsi_content` | [[percorso-read]] |
| Step start/complete | — | `POST /path/steps/{stepId}/start|complete` | [[percorso]] |
| Diario voci | `GET/POST /api/diary` | GraphQL `user_activities` (read) + `/journal/goals` (write) | [[diario-attivita]] / [[diario]] |
| Traguardi | `GET /api/diary/achievements` | `GET /journal/goals` | [[diario]] |
| Statistiche | `GET /api/statistics?month=` | GraphQL `user_activities_aggregated` | [[diario-attivita]] |
| Benefit | `GET /api/benefits`, `/redeem` | GraphQL `partners` (`coupon` è un campo) | [[benefit-partner]] |
| Momenti | `GET /api/moments` | GraphQL `moments` | [[momenti]] |
| Notifiche | `GET /api/notifications`, `PATCH …` | GraphQL `user_notifications` + mutation | [[notifiche]] |
| Profilo | `GET/PATCH /api/profile` | `PATCH /profile` (write) + GraphQL `GetUserDetails` (read) | [[profilo]] / [[profilo-read]] |
| Silhouette | `GET /api/profile/silhouette` | derivato da `user_details` (gender/profile) | [[profilo-read]] |
| Promemoria | `GET/POST/PATCH/DELETE /api/reminders` | `/tools/reminders*` | [[strumenti]] |
| Timer | nessuno | nessuno (client-side, config CMS) | [[strumenti-read]] |
| Glossario | `GET /api/glossary` | GraphQL `glossary` | [[strumenti-read]] |
| Foto progressi | `GET/POST/DELETE /api/progress-photos` | GraphQL `user_photos` (read) + `/tools/photo-gallery` (write) | [[strumenti-read]] / [[strumenti]] |
| Preferiti | (non elencato) | GraphQL `user_favourites` + mutation | [[preferiti]] |

## Note ancora aperte

- **Push notifications:** non implementate (`job_channel: web_app` solo). Vedi [[notifiche]].
- **SDL GraphQL pubblico:** `moments`, `percorsi*`, `timer` non compaiono nello SDL pubblico —
  richiedono ruolo autenticato. Campi presi dallo Swagger. Vedi [[contradictions]] §5.
- **Survey questions:** lo Swagger non documenta una query GraphQL d'esempio per le domande;
  confermare i campi di `surveys`/`survey_sections`/`survey_question` col team.

---

## Storico (proposte originali)

> Il testo sotto è la versione pre-Swagger (2026-06-08), conservato per riferimento. Gli
> endpoint `/api/*` qui descritti **non sono il contratto reale** — usare la tabella sopra.

<details>
<summary>Proposte originali (pre-Swagger)</summary>

Le schermate dell'app di programma richiedevano endpoint che non esistevano in
documentazione (allora si conosceva solo lo shop). La sorgente dati ipotizzata era il CMS
Directus via proxy. Aree coperte: Onboarding/Survey, Prova d'acquisto, Home/Hero,
Abilitazioni contenuti, Percorso (overview + hub), Diario & Traguardi, Statistiche, Benefit,
Momenti, Notifiche, Profilo & Silhouette, Strumenti (Promemoria/Timer/Glossario/Foto).
Tutte risolte nella tabella sopra.

</details>

## Related

- [[overview]]
- [[contradictions]]
- [[graphql]]
- [[missing-informations]]
