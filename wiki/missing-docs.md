# Kilocal App — Documentazione API mancante

**Progetto:** App Kilocal (programma fitness/benessere)
**Documento:** Elenco delle API non documentate, necessarie per lo sviluppo
**Data:** 8 giugno 2026
**Stato:** Da confermare con il team back-end del cliente

---

## Sintesi

La documentazione tecnica attualmente fornita copre **soltanto la parte shop / e-commerce**
(autenticazione, carrello, ordini, pagamenti PayPal, utenti, indirizzi, impostazioni).

Tutte le schermate dell'**app di programma** presenti nel flusso di design (onboarding,
home, percorso, diario, statistiche, benefit, momenti, notifiche, profilo e strumenti)
richiedono dati e operazioni di rete per cui **non esiste alcun endpoint documentato**.

Per poter procedere con lo sviluppo serve, per ciascuna area elencata di seguito, che il
team back-end **confermi gli endpoint, i metodi e il formato dei dati** (oppure indichi
dove tali contenuti sono già esposti, ad es. tramite il CMS). Gli endpoint riportati qui
sotto sono **proposte di lavoro**, non contratti già esistenti, e servono a evidenziare il
dato necessario a ogni schermata.

> **Nota importante (sorgente dati).** Parte di questi contenuti potrebbe essere già
> disponibile dal CMS del prodotto. In tal caso, invece di nuovi endpoint, è sufficiente
> che il team fornisca la **struttura dei contenuti** (collezioni e campi) corrispondente.

---

## 1. Onboarding & Survey

### 1.1 Survey iniziale / finale
- **Serve per:** recuperare le domande del questionario, inviare le risposte
  (preimpostate o libere), ricevere il **kit / biotipo consigliato**.
- **Endpoint proposti:**
  - `GET /api/survey/{type}` → domande del survey (`type` = `initial` | `final`)
  - `POST /api/survey/{type}/answers` → invio risposte, ritorna risultato/kit consigliato
- **Note:** include schermate di testo informativo e schermata "Risultato kit".

### 1.2 Prova d'acquisto
- **Serve per:** validare il **codice di prova d'acquisto** inserito dall'utente per
  sbloccare la piattaforma.
- **Endpoint proposto:**
  - `POST /api/proof-of-purchase` → body `{ "code": "..." }`, valida e abilita l'accesso

---

## 2. Home

### 2.1 Stato programma + Home/Hero
- **Serve per:** card di benvenuto, **progresso complessivo (%)**, contenuti del
  **carosello hero**.
- **Endpoint proposti:**
  - `GET /api/program/status` → stato/avanzamento programma dell'utente
  - `GET /api/home/hero` → elenco contenuti hero (immagini + titoli)

---

## 3. Percorso

### 3.1 Percorso (overview)
- **Serve per:** "Il tuo percorso", **progressi complessivi**, hub
  Allenamento / Alimentazione / Benessere / Integrazione, vista "Info" con stato attività
  per mese/fase.
- **Endpoint proposti:**
  - `GET /api/path` → struttura del percorso + stato completamento
  - `GET /api/path/progress` → dettaglio attività completate per mese/fase

### 3.2 Hub di percorso (contenuti)
- **Serve per:** elenco contenuti per ciascun hub (Allenamento, Alimentazione, Benessere,
  Integrazione, Materiali Extra), pagina di dettaglio (step, attività, immagini, timer),
  dettaglio prodotto.
- **Endpoint proposti:**
  - `GET /api/path/{hub}` → contenuti dell'hub (`hub` = `training` | `nutrition` |
    `wellbeing` | `supplements` | `materials`)
  - `GET /api/path/{hub}/{contentId}` → dettaglio singolo contenuto
- **Note:** l'hub Allenamento mostra un **timer** (a tendina) per le sessioni.

---

## 4. Diario & Traguardi

- **Serve per:** voci del diario, **traguardi**, modale filtri, tendine info,
  dettaglio prodotto.
- **Endpoint proposti:**
  - `GET /api/diary` → voci diario (con filtri)
  - `POST /api/diary` → creazione voce diario
  - `GET /api/diary/achievements` → traguardi raggiunti

---

## 5. Statistiche

- **Serve per:** percentuali attività del **mese corrente** per area
  (Allenamento, Alimentazione, Benessere, Integrazione) con conteggio `x/y attività`.
- **Endpoint proposto:**
  - `GET /api/statistics?month={n}` → percentuali e conteggi per area/mese

---

## 6. Benefit

- **Serve per:** elenco **benefit attivi**, modale filtri, dettaglio benefit,
  **codici sconto partner** (es. Twitch, Spotify).
- **Endpoint proposti:**
  - `GET /api/benefits` → elenco benefit (attivi / coming soon)
  - `GET /api/benefits/{id}` → dettaglio benefit
  - `POST /api/benefits/{id}/redeem` → generazione/recupero codice sconto partner

---

## 7. Momenti

- **Serve per:** contenuti editoriali / **challenge** con meccanica (es. "Ogni giorno per
  7 giorni…").
- **Endpoint proposto:**
  - `GET /api/moments` / `GET /api/moments/{id}` → contenuti momenti / dettaglio

---

## 8. Notifiche

- **Serve per:** lista notifiche, modale filtri (Tutte / Categoria / Archiviate),
  **archiviazione tramite swipe**, varie tipologie (con immagine, con pulsanti CTA).
- **Endpoint proposti:**
  - `GET /api/notifications?filter={all|archived|category}` → lista
  - `PATCH /api/notifications/{id}` → archivia / segna come letta
- **Note:** prevedere un conteggio non lette per il badge nella barra di navigazione.

---

## 9. Profilo & Silhouette

- **Serve per:** dati profilo, **tipo / biotipo corporeo**, **silhouette** (7 tipi),
  parti del corpo interessate, schede voci-testo, tendine info, redirect esterno.
- **Endpoint proposti:**
  - `GET /api/profile` → dati profilo utente
  - `PATCH /api/profile` → aggiornamento profilo
  - `GET /api/profile/silhouette` → tipo/biotipo + parti interessate (7 varianti)

---

## 10. Strumenti

La sezione Strumenti raggruppa quattro tool: **Promemoria**, **Timer**, **Glossario**,
**Foto progressi**. Nessuno di essi ha API documentate.

### 10.1 Promemoria
- **Serve per:** creazione/modifica/eliminazione dei promemoria utente con data, ora e note;
  vista calendario mensile.
- **Endpoint proposti:**
  - `GET /api/reminders` → elenco promemoria (filtrabile per mese/data)
  - `POST /api/reminders` → creazione promemoria `{ title, date, time, note }`
  - `PATCH /api/reminders/{id}` → modifica
  - `DELETE /api/reminders/{id}` → eliminazione
- **Da chiarire:** i promemoria devono essere **sincronizzati** col back-end o gestiti
  **solo localmente** sul dispositivo (notifiche on-device)? Nel secondo caso non serve
  alcuna API.

### 10.2 Timer
- **Serve per:** funzione timer/cronometro con selezione suoneria.
- **Endpoint:** **nessuno** — funzionalità **interamente locale** al dispositivo.
- **Da chiarire:** l'elenco delle suonerie è fisso nell'app o gestito da remoto?

### 10.3 Glossario
- **Serve per:** ricerca di termini per parola chiave o lettera iniziale (A–Z); ogni voce
  ha titolo e definizione.
- **Endpoint proposti:**
  - `GET /api/glossary?q={term}&letter={A-Z}` → voci corrispondenti
  - in alternativa `GET /api/glossary` (lista completa, ricerca lato client)
- **Note:** contenuto editoriale, probabilmente gestibile dal CMS.

### 10.4 Foto progressi
- **Serve per:** caricare e archiviare foto dei progressi corporei, confrontarle affiancate
  (split image), salvare/condividere il confronto.
- **Endpoint proposti:**
  - `GET /api/progress-photos` → elenco foto utente
  - `POST /api/progress-photos` → upload foto (multipart) `{ image, date, label }`
  - `DELETE /api/progress-photos/{id}` → eliminazione
- **Da chiarire:** trattandosi di **dati sensibili** (foto corporee), l'archiviazione deve
  essere **locale al dispositivo** o **cloud** con storage privato e autenticazione?

---

## Riepilogo endpoint proposti

| Area | Endpoint proposti |
|------|-------------------|
| Survey | `GET /api/survey/{type}`, `POST /api/survey/{type}/answers` |
| Prova d'acquisto | `POST /api/proof-of-purchase` |
| Home | `GET /api/program/status`, `GET /api/home/hero` |
| Percorso | `GET /api/path`, `GET /api/path/progress`, `GET /api/path/{hub}`, `GET /api/path/{hub}/{contentId}` |
| Diario | `GET /api/diary`, `POST /api/diary`, `GET /api/diary/achievements` |
| Statistiche | `GET /api/statistics?month={n}` |
| Benefit | `GET /api/benefits`, `GET /api/benefits/{id}`, `POST /api/benefits/{id}/redeem` |
| Momenti | `GET /api/moments`, `GET /api/moments/{id}` |
| Notifiche | `GET /api/notifications`, `PATCH /api/notifications/{id}` |
| Profilo | `GET /api/profile`, `PATCH /api/profile`, `GET /api/profile/silhouette` |
| Promemoria | `GET/POST /api/reminders`, `PATCH/DELETE /api/reminders/{id}` (o solo locale) |
| Timer | nessuno (locale) |
| Glossario | `GET /api/glossary?q=&letter=` |
| Foto progressi | `GET/POST /api/progress-photos`, `DELETE /api/progress-photos/{id}` (o solo locale) |

---

## Cosa serve dal team back-end

Per ciascuna area sopra, chiediamo di confermare:

1. **Esistenza dell'endpoint** — l'API esiste già? Se sì, con quale URL e metodo?
2. **Formato dei dati** — struttura della risposta (campi) e del payload in invio.
3. **Sorgente** — il dato proviene da API dedicate o dai contenuti del CMS? In quest'ultimo
   caso, indicare collezioni e campi.
4. **Autenticazione** — l'app di programma e lo shop condividono lo stesso login e lo stesso
   back-end, oppure sono sistemi distinti?
5. **Funzioni locali vs sincronizzate** — per Promemoria, Timer e Foto progressi, confermare
   se devono essere salvati sul server o gestiti solo sul dispositivo.
