# Informazioni mancanti / incongruenze

Analisi di confronto tra le immagini Figma in `wiki/flow-screen/` e la documentazione
presente nella wiki (file `.md`). Aggiornato il **2026-06-08**.

> **Conclusione principale:** la wiki documenta quasi esclusivamente le **API dello shop
> e-commerce** (carrello, ordini, PayPal, indirizzi, utenti, impostazioni) e **una sola
> schermata** ([[screen-splash]]). Il flusso Figma descrive invece un'intera **app di
> programma fitness/benessere** (home, percorso, diario, statistiche, profilo, notifiche,
> benefit, ecc.) che **non è documentata**. C'è quindi un forte disallineamento tra ciò che
> la wiki descrive (back-end shop) e ciò che il design mostra (app cliente del programma).

---

## 1. Schermate presenti nel Figma ma assenti dalla wiki

Nella wiki è documentata solo la schermata **Splash** ([[screen-splash]]). Tutte le seguenti
schermate del flusso Figma **non hanno un file `.md` corrispondente**:

| Immagine Figma | Schermata / Flusso | Stato wiki |
|----------------|--------------------|------------|
| `splash.png` | Splash + **Approdo sales speech** (carosello onboarding "N STEP") | Splash documentato, ma **manca il carosello onboarding** post-splash |
| `login.png` | **Login / Sign up** (Accedi, Registrati) | Esistono solo le API ([[authentication]], [[users]]); **manca la documentazione delle schermate UI** |
| `survey-iniziale.png` | **Survey iniziale** (domande, risposte preimpostate/libere, testi informativi, risultato kit) | **Mancante del tutto** (UI e API) |
| `prova-acquisto-iniziale.png` | **Inserimento prova d'acquisto + Survey finale** (intermezzo, inserisci codice, domande alimentazione, intro piattaforma) | **Mancante del tutto** (UI e API) |
| `hero-home.png` | **Home / Hero Home** (card "Ciao Management", progresso 80%, carosello hero) | **Mancante del tutto** |
| `percorso1.png` | **Percorso** (Il tuo percorso, progressi complessivi, hub Allenamento/Alimentazione/Benessere/Integrazione) + Info | **Mancante del tutto** |
| `percorso2.png` | **Allenamento Hub** + pagina allenamento + timer tendina + contenuto | **Mancante del tutto** |
| `percorso3.png` | **Alimentazione Hub** + pagina alimentazione (step, attività) | **Mancante del tutto** |
| `percorso4.png` | **Benessere Hub** + categoria benessere (mindfulness, self care, stili di vita) | **Mancante del tutto** |
| `percorso5.png` | **Integrazione Hub** + pagina integrazione + tendina info + dettaglio prodotto | **Mancante del tutto** |
| `percorso6.png` | **Materiali Extra Hub** + pagina materiale + modale filtri | **Mancante del tutto** |
| `diario1.png` | **Diario** + modale filtri + tendine info + dettaglio prodotto | **Mancante del tutto** |
| `diario2.png` | **Traguardo** (modale filtri, info, dettaglio prodotto) | **Mancante del tutto** |
| `statistiche.png` | **Statistiche** (mese corrente: allenamento, alimentazione, benessere, integrazione con %) | **Mancante del tutto** |
| `benefit.png` | **Benefit** (benefit attivi, modale filtri, dettaglio benefit, codici sconto partner es. Twitch/Spotify) | **Mancante del tutto** |
| `momenti.png` | **Momenti** (contenuto editoriale / challenge / meccanica) | **Mancante del tutto** |
| `notifiche.png` | **Notifiche** (lista, modale filtri, tipologie notifiche, archiviazione swipe) | **Mancante del tutto** |
| `profilo1.png` | **Profilo** (contenuti, tipo, silhouette corpo, parti interessate, tendine info, redirect esterno) | **Mancante del tutto** |
| `profilo2.png` | **Profilo — voci testo** (schede prodotto/informative) | **Mancante del tutto** |
| `profilo3.png` | **Profilo — Silhouette** (7 tipi di silhouette/biotipo corporeo) | **Mancante del tutto** |
| `strumenti1.png` | **Strumenti — Promemoria** (calendario mensile, aggiungi/modifica/dettaglio promemoria) | **Mancante del tutto** |
| `strumenti2.png` | **Strumenti — Timer** (count-up/count-down, suoneria) **+ Glossario** (ricerca, selettore A–Z, accordion) | **Mancante del tutto** |
| `strumenti3.png` | **Strumenti — Foto progressi** (gallery, upload, split image confronto corpo, salva/condividi) | **Mancante del tutto** |

---

## 2. Elementi di design / navigazione non documentati

- **Bottom navigation bar a 5 tab**: presente in quasi tutte le schermate principali
  (Home, Percorso, Diario/centro, Profilo, e una quinta icona "goccia"/integrazione).
  Non è documentata in [[design-system]] né in [[flutter-architecture]] (il `GoRouter`
  descritto non prevede una shell con tab/`StatefulShellRoute`).
- **Pattern ricorrenti non documentati**: "modale filtri", "tendine info" (bottom sheet),
  "dettaglio prodotto", schede hub con stato di completamento e percentuali.
- **Design system incompleto**: [[design-system]] dichiara esplicitamente che tipografia,
  scala di spaziatura, raggi degli angoli ed elevazioni **non sono ancora catturati**. Le
  schermate del flusso (card bianche con ombre, badge percentuale circolari, liste, timer)
  forniscono materiale per completare questi token, ma non è stato fatto.
- **Tema chiaro vs scuro**: lo splash e l'onboarding usano lo sfondo gradiente brand
  (rosa→cremisi), mentre l'app interna (home, percorso, diario...) usa uno **sfondo chiaro**
  con accenti rossi. [[design-system]] descrive solo il gradiente brand: manca la palette
  delle superfici chiare usate nell'app vera e propria.

---

## 2bis. Livelli di accesso utente / contenuti bloccati (gating)

Dal Figma emerge che **non tutti gli utenti hanno accesso a tutti i contenuti**: alcune tab/hub
del percorso possono apparire in stato **"bloccato"** (es. un utente vede e usa la tab
**Allenamento** ma altre tab risultano bloccate). Questo implica l'esistenza di **livelli di
accesso / abilitazioni** per utente — non documentati da nessuna parte.

- **Cosa manca nella wiki:** la documentazione tratta i livelli di accesso solo in termini di
  **autenticazione di endpoint** (Public / Authenticated / Server only in [[authentication]]).
  **Non esiste** alcuna descrizione di un modello di **autorizzazione per contenuto** (quali
  hub/tab/aree sono sbloccati per quale utente).
- **Cosa mostra il design:** stato visivo **bloccato/sbloccato** sulle tile degli hub di
  [[screen-path]] (Allenamento, Alimentazione, Benessere, Integrazione, Materiali Extra) e,
  potenzialmente, su altre sezioni.
- **Domande aperte (da confermare col team):**
  1. Cosa determina lo sblocco? Possibili driver: **kit/biotipo** dalla survey, **codice prova
     d'acquisto** validato, **tier/abbonamento** dell'utente, **fase/mese** del percorso, o un
     **ruolo Directus**.
  2. Lo sblocco è **statico** (impostato all'attivazione del programma) o **progressivo**
     (si sblocca avanzando nel percorso)?
  3. È un attributo dell'utente, della sua iscrizione al programma, o dei singoli contenuti CMS?
  4. Lo stato "bloccato" è solo **UI** o l'API **nega** anche l'accesso ai contenuti dell'hub?
- **Impatto sviluppo:** la UI deve rendere lo stato bloccato (badge/lucchetto, tap → messaggio o
  redirect all'acquisto/upgrade) e l'app deve ricevere dal back-end le **abilitazioni per utente**.
  Vedi [[missing-apis]] (§2bis) per il dato/endpoint necessario.

> ⚠️ Manca la **schermata Figma** che mostra esplicitamente questo stato: andrebbe esportata in
> `wiki/flow-screen/` e collegata qui per documentare l'esatto comportamento.

---

## 3. API documentate senza schermata corrispondente nel flusso

Le seguenti API sono documentate ma **non trovano riscontro in nessuna schermata** del flusso
Figma fornito (lo shop e-commerce non è rappresentato nelle immagini):

| API / Pagina wiki | Schermata attesa | Riscontro nel Figma |
|-------------------|------------------|---------------------|
| [[cart]] / [[cart-data-model]] | Carrello, lista articoli, riepilogo | **Assente** |
| [[orders]] | Riepilogo/conferma ordine | **Assente** |
| [[paypal]] | Checkout / pagamento PayPal | **Assente** |
| [[user-addresses]] | Gestione indirizzi (spedizione/fatturazione) | **Assente** |
| [[settings]] | Schermata impostazioni | **Assente** (esiste "Profilo" ma non mappato a `/api/settings`) |
| [[finder]] / [[cms-proxy]] | (routing interno, nessuna UI) | N/D |

> Da chiarire: lo shop e-commerce documentato e l'app di programma del Figma sono **due
> prodotti/sezioni distinti**, oppure il flusso d'acquisto va aggiunto al design? Le
> schermate di onboarding parlano di "kit", "prova d'acquisto" e "intro piattaforma",
> suggerendo un collegamento tra acquisto del kit (shop) e accesso al programma (app).

---

## 4. Funzionalità nel flusso senza API documentata

Le seguenti schermate implicano chiamate di rete / dati che **non hanno endpoint documentato**
nella wiki (l'unica documentazione API riguarda lo shop):

| Schermata | Dato / azione presunti | API documentata? |
|-----------|------------------------|------------------|
| Survey iniziale / finale | Invio risposte, calcolo kit/biotipo consigliato | **No** |
| Prova d'acquisto | Validazione codice prova d'acquisto | **No** |
| Home / Hero | Stato programma, progresso %, contenuti hero | **No** |
| Percorso (Allenamento, Alimentazione, Benessere, Integrazione, Materiali) | Recupero contenuti percorso, stato completamento, attività | **No** |
| Diario / Traguardo | Voci diario, traguardi, dettaglio prodotto | **No** |
| Statistiche | Percentuali attività per mese/fase | **No** |
| Benefit | Elenco benefit attivi, codici sconto partner | **No** |
| Momenti | Contenuti editoriali / challenge | **No** |
| Notifiche | Lista, filtri, archiviazione notifiche | **No** |
| Profilo / Silhouette | Dati profilo, biotipo, parti del corpo interessate | **No** |
| Strumenti — Promemoria | CRUD promemoria (data, ora, note) — o solo locale | **No** |
| Strumenti — Timer | Timer/cronometro — feature client-side, nessuna API | **No** (client-side) |
| Strumenti — Glossario | Voci glossario (ricerca per parola/lettera) | **No** |
| Strumenti — Foto progressi | Upload/archiviazione/confronto foto corporee — o solo locale | **No** |

> Probabile sorgente dati: GraphQL/REST CMS Directus via [[cms-proxy]] (collezioni contenuti),
> ma **non esiste documentazione degli endpoint specifici** (collezioni, query, schema) per
> percorso, diario, statistiche, benefit, notifiche e profilo.

---

## 5. Incongruenze puntuali nella schermata Splash

[[screen-splash]] è documentata, ma rispetto a `splash.png` emerge che:

- Il titolo del frame Figma è **"SPLASH + APPRODO SALES SPEECH"**: dopo lo splash è previsto
  un **carosello di onboarding ("N STEP")** con testo ("Lorem Ipsum", "Inizia a lorem ipsum"),
  indicatori di pagina e pulsanti avanti/inizia. La wiki descrive lo splash come schermata
  **senza testo né pulsanti**, ma **non menziona il carosello di onboarding** che segue.
- Di conseguenza il routing descritto ("splash → home o login") è incompleto: manca il
  passaggio intermedio **splash → onboarding/sales speech → login/survey**.

---

## Azioni consigliate

1. Confermare con il team se shop e-commerce e app di programma sono lo stesso prodotto e come
   si collegano (acquisto kit ↔ accesso programma).
2. Creare le pagine wiki mancanti per le schermate del flusso (almeno: onboarding, login UI,
   survey, home, percorso e sotto-hub, diario, statistiche, benefit, momenti, notifiche,
   profilo/silhouette).
3. Documentare gli endpoint (probabilmente CMS Directus via [[cms-proxy]]) che alimentano le
   schermate del programma: collezioni, query GraphQL e schema dati.
4. Completare [[design-system]] con tipografia, spaziature, raggi, ombre, palette superfici
   chiare e la **bottom navigation a 5 tab**.
5. Aggiornare [[screen-splash]] e [[flutter-architecture]] (router) per includere il carosello
   di onboarding post-splash e la shell con tab di navigazione.
6. Definire con il team il **modello di accesso ai contenuti** (vedi §2bis): cosa sblocca gli
   hub/tab, se lo sblocco è statico o progressivo, e come l'app riceve le abilitazioni per
   utente. Esportare la schermata Figma con lo stato "bloccato" in `wiki/flow-screen/`.

## Related

- [[README]]
- [[contradictions]]
- [[screen-splash]]
- [[design-system]]
- [[flutter-architecture]]
