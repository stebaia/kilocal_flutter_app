# API mancanti

Elenco e descrizione delle **API non documentate** ma necessarie per alimentare le schermate
del flusso Figma (`wiki/flow-screen/`). La wiki attuale documenta solo le API dello **shop
e-commerce** ([[cart]], [[orders]], [[paypal]], [[user-addresses]], [[users]], [[settings]]);
le schermate dell'**app di programma fitness/benessere** richiedono endpoint che **non esistono
in documentazione**. Aggiornato il **2026-06-08**. Vedi anche [[missing-informations]].

> **Sorgente dati probabile:** la maggior parte di questi contenuti arriva verosimilmente dal
> **CMS Directus** tramite [[cms-proxy]] (`POST /cms/graphql`, `GET /cms/items/{collection}`).
> L'infrastruttura proxy è documentata, ma **mancano le collezioni, le query GraphQL e lo
> schema dati** specifici. Gli endpoint indicati sotto sono **proposte da confermare** con il
> team, non contratti esistenti.

---

## 1. Onboarding & Survey

### 1.1 Survey iniziale / finale
- **Schermate:** `survey-iniziale.png`, `prova-acquisto-iniziale.png`
- **Serve per:** recuperare le domande del questionario, inviare le risposte
  (preimpostate o libere), ricevere il **kit / biotipo consigliato**.
- **Endpoint proposti:**
  - `GET /api/survey/{type}` → domande del survey (`type` = `initial` | `final`)
  - `POST /api/survey/{type}/answers` → invio risposte, ritorna risultato/kit consigliato
- **Note:** include schermate di testo informativo e schermata "Risultato kit".

### 1.2 Prova d'acquisto
- **Schermata:** `prova-acquisto-iniziale.png`
- **Serve per:** validare il **codice di prova d'acquisto** inserito dall'utente per
  sbloccare la piattaforma.
- **Endpoint proposto:**
  - `POST /api/proof-of-purchase` → body `{ "code": "..." }`, valida e abilita l'accesso

---

## 2. Home

### 2.1 Stato programma + Home/Hero
- **Schermate:** `hero-home.png`
- **Serve per:** card "Ciao Management", **progresso complessivo (%)**, contenuti del
  **carosello hero**.
- **Endpoint proposti:**
  - `GET /api/program/status` → stato/avanzamento programma dell'utente
  - `GET /api/home/hero` → elenco contenuti hero (immagini + titoli)

---

## 3. Percorso

### 3.1 Percorso (overview)
- **Schermata:** `percorso1.png`
- **Serve per:** "Il tuo percorso", **progressi complessivi**, hub
  Allenamento / Alimentazione / Benessere / Integrazione, vista "Info" con stato attività
  per mese/fase.
- **Endpoint proposti:**
  - `GET /api/path` → struttura del percorso + stato completamento
  - `GET /api/path/progress` → dettaglio attività completate per mese/fase

### 3.2 Hub di percorso (contenuti)
- **Schermate:** `percorso2.png` (Allenamento), `percorso3.png` (Alimentazione),
  `percorso4.png` (Benessere), `percorso5.png` (Integrazione), `percorso6.png` (Materiali Extra)
- **Serve per:** elenco contenuti per ciascun hub, pagina di dettaglio (step, attività,
  immagini, timer), dettaglio prodotto.
- **Endpoint proposti:**
  - `GET /api/path/{hub}` → contenuti dell'hub (`hub` = `training` | `nutrition` |
    `wellbeing` | `supplements` | `materials`)
  - `GET /api/path/{hub}/{contentId}` → dettaglio singolo contenuto
- **Note:** `percorso2` mostra un **timer** (tendina) per le sessioni di allenamento.

---

## 4. Diario & Traguardi

- **Schermate:** `diario1.png`, `diario2.png`
- **Serve per:** voci del diario, **traguardi**, modale filtri, tendine info,
  dettaglio prodotto.
- **Endpoint proposti:**
  - `GET /api/diary` → voci diario (con filtri)
  - `POST /api/diary` → creazione voce diario
  - `GET /api/diary/achievements` → traguardi raggiunti

---

## 5. Statistiche

- **Schermata:** `statistiche.png`
- **Serve per:** percentuali attività del **mese corrente** per area
  (Allenamento, Alimentazione, Benessere, Integrazione) con conteggio `x/y attività`.
- **Endpoint proposto:**
  - `GET /api/statistics?month={n}` → percentuali e conteggi per area/mese

---

## 6. Benefit

- **Schermata:** `benefit.png`
- **Serve per:** elenco **benefit attivi**, modale filtri, dettaglio benefit,
  **codici sconto partner** (es. Twitch, Spotify).
- **Endpoint proposti:**
  - `GET /api/benefits` → elenco benefit (attivi / coming soon)
  - `GET /api/benefits/{id}` → dettaglio benefit
  - `POST /api/benefits/{id}/redeem` → generazione/recupero codice sconto partner

---

## 7. Momenti

- **Schermata:** `momenti.png`
- **Serve per:** contenuti editoriali / **challenge** con meccanica (es. "Ogni giorno per
  7 giorni…").
- **Endpoint proposto:**
  - `GET /api/moments` / `GET /api/moments/{id}` → contenuti momenti / dettaglio

---

## 8. Notifiche

- **Schermata:** `notifiche.png`
- **Serve per:** lista notifiche, modale filtri (Tutte / Categoria / Archiviate),
  **archiviazione tramite swipe**, varie tipologie (con immagine, con pulsanti CTA).
- **Endpoint proposti:**
  - `GET /api/notifications?filter={all|archived|category}` → lista
  - `PATCH /api/notifications/{id}` → archivia / segna come letta
- **Note:** prevedere conteggio non lette per il badge in bottom bar.

---

## 9. Profilo & Silhouette

- **Schermate:** `profilo1.png`, `profilo2.png`, `profilo3.png`
- **Serve per:** dati profilo, **tipo / biotipo corporeo**, **silhouette** (7 tipi),
  parti del corpo interessate, schede voci-testo, tendine info, redirect esterno.
- **Endpoint proposti:**
  - `GET /api/profile` → dati profilo utente
  - `PATCH /api/profile` → aggiornamento profilo
  - `GET /api/profile/silhouette` → tipo/biotipo + parti interessate (7 varianti)

---

## 10. Strumenti

Schermate: `strumenti1.png` (Promemoria), `strumenti2.png` (Timer + Glossario),
`strumenti3.png` (Foto progressi). La home Strumenti raggruppa quattro tool:
**Promemoria**, **Timer**, **Glossario**, **Foto progressi**. **Nessuna API documentata**
nel doc tecnico (`raw/KILOCAL DOCUMENTAZIONE TECNICA.pdf`), che copre solo shop/cart/orders/
paypal/users/user-addresses/finder/CMS proxy.

### 10.1 Promemoria
- **Schermate:** `strumenti1.png` — vista **Calendario** (mese), liste promemoria,
  schermate "Aggiungi promemoria", "Modifica promemoria", "Dettaglio promemoria",
  selezione data/ora.
- **Serve per:** CRUD dei promemoria utente con data, ora e note; vista calendario mensile.
- **Endpoint proposti:**
  - `GET /api/reminders` → elenco promemoria (filtrabile per mese/data)
  - `POST /api/reminders` → creazione promemoria `{ title, date, time, note }`
  - `PATCH /api/reminders/{id}` → modifica
  - `DELETE /api/reminders/{id}` → eliminazione
- **Note:** valutare se i promemoria sono **solo locali** (notifiche on-device) oppure
  sincronizzati col back-end. Se locali, **nessuna API serve** — solo storage locale +
  notifiche pianificate.

### 10.2 Timer
- **Schermate:** `strumenti2.png` — timer con count-up (`00:32:48`) e count-down
  circolare (`01:40`), controlli avvia/interrompi/pausa; nota "CAMBIO SUONERIA?".
- **Serve per:** funzione timer/cronometro locale; selezione suoneria.
- **Endpoint proposti:** **nessuno** — feature **interamente client-side** (timer locale,
  notifica/suoneria on-device). Da confermare se la lista suonerie è statica o remota.

### 10.3 Glossario
- **Schermate:** `strumenti2.png` — campo "Parola chiave", selettore alfabetico (A–Z),
  "Risultati corrispondenti" in accordion espandibili con definizione.
- **Serve per:** ricerca termini del glossario per parola chiave / lettera iniziale;
  voci con titolo + definizione.
- **Endpoint proposti:**
  - `GET /api/glossary?q={term}&letter={A-Z}` → voci corrispondenti
  - oppure `GET /api/glossary` (lista completa, ricerca/filtro lato client)
- **Note:** contenuto editoriale: probabile **collezione Directus** via [[cms-proxy]].

### 10.4 Foto progressi
- **Schermate:** `strumenti3.png` — "Foto Gallery"/"Le tue foto", upload foto,
  "Split image titolo strumenti" (confronto due foto affiancate), selezione foto,
  salva/condividi, tendine info.
- **Serve per:** caricare e archiviare foto dei progressi corporei, confrontarle
  affiancate (split image), salvare/condividere il confronto.
- **Endpoint proposti:**
  - `GET /api/progress-photos` → elenco foto utente
  - `POST /api/progress-photos` → upload foto (multipart) `{ image, date, label }`
  - `DELETE /api/progress-photos/{id}` → eliminazione
- **Note:** dati **sensibili** (foto corporee) → richiede storage privato e autenticazione.
  Valutare se l'archiviazione è **solo locale** (privacy) o cloud sincronizzata.

---

## Riepilogo endpoint proposti

| Area | Endpoint proposti | Schermata |
|------|-------------------|-----------|
| Survey | `GET /api/survey/{type}`, `POST /api/survey/{type}/answers` | survey-iniziale, prova-acquisto-iniziale |
| Prova d'acquisto | `POST /api/proof-of-purchase` | prova-acquisto-iniziale |
| Home | `GET /api/program/status`, `GET /api/home/hero` | hero-home |
| Percorso | `GET /api/path`, `GET /api/path/progress`, `GET /api/path/{hub}`, `GET /api/path/{hub}/{contentId}` | percorso1–6 |
| Diario | `GET /api/diary`, `POST /api/diary`, `GET /api/diary/achievements` | diario1, diario2 |
| Statistiche | `GET /api/statistics?month={n}` | statistiche |
| Benefit | `GET /api/benefits`, `GET /api/benefits/{id}`, `POST /api/benefits/{id}/redeem` | benefit |
| Momenti | `GET /api/moments`, `GET /api/moments/{id}` | momenti |
| Notifiche | `GET /api/notifications`, `PATCH /api/notifications/{id}` | notifiche |
| Profilo | `GET /api/profile`, `PATCH /api/profile`, `GET /api/profile/silhouette` | profilo1–3 |
| Promemoria | `GET/POST /api/reminders`, `PATCH/DELETE /api/reminders/{id}` (o solo locale) | strumenti1 |
| Timer | nessuno (client-side) | strumenti2 |
| Glossario | `GET /api/glossary?q=&letter=` (probabile Directus) | strumenti2 |
| Foto progressi | `GET/POST /api/progress-photos`, `DELETE /api/progress-photos/{id}` (o solo locale) | strumenti3 |

---

## Avvertenze

- Tutti gli endpoint sopra sono **proposte**, non documentati: vanno **confermati con il team
  back-end**. È possibile che molti siano già coperti da query GraphQL/REST su collezioni
  Directus via [[cms-proxy]], nel qual caso va documentato lo **schema delle collezioni** invece
  di nuovi endpoint `/api/*`.
- Da chiarire se l'**app di programma** e lo **shop e-commerce** condividano la stessa
  autenticazione ([[authentication]]) e lo stesso back-end, o siano sistemi distinti.

## Related

- [[missing-informations]]
- [[cms-proxy]]
- [[authentication]]
- [[README]]
