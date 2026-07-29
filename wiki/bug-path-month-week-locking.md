# Bug: navigazione mensile percorso (Allenamento/Alimentazione) + blocco settimanale mancante

Analisi tecnica dei 3 problemi segnalati (2026-07-28). Nessun codice toccato — solo diagnosi, per allineare backend/Anna prima di implementare.

Riferimenti: [[path-feature-status]], `wiki/path-implementation-plan.md`.

## Segnalazione originale

> La navigazione fra i moduli allenamento (e alimentazione) non funziona. La tendina non mi permette di aprire gli allenamenti passati. SUCCEDE SOLO QUANDO COMPLETI IL MESE. Funziona invece se ci sono ancora moduli da fare.
>
> Inoltre se clicco sul mese successivo mi dà il blocco ed è corretto come funzionamento. Ma il messaggio deve essere quello di "per sbloccare la sezione completa: XXXXX del mese corrente" invece che come ora dove esce un messaggio generico e fuorviante "devi completare gli esercizi precedenti". I testi precisi chiedili ad Anna. Quindi in base a cosa manca per completare il mese, l'alert deve riportare quelle info.
>
> Inoltre non c'è il blocco per i moduli del mese delle settimane successive. Se faccio i moduli della settimana 1 non posso fare quelli della settimana 2 finché non passa il tempo. Deve uscire alert con CTA alternativa "intanto guarda contenuti extra" che porta alla sezione contenuti extra.

## Architettura attuale (per orientamento)

Non esiste una vera "tendina": la lista mesi è una colonna di righe (`PathTimeframeRow`), una per `timeframe` ("1° mese", "2° mese"...), ciascuna con badge % o lucchetto.

- `lib/features/path/presentation/path_area_detail_screen.dart:209-218` — lista mesi, tap su riga bloccata → `showTimeframeLockedSheet` (riga 215-217)
- `lib/features/path/presentation/widgets/path_timeframe_row.dart` — badge % / lucchetto, riga 100-134
- `lib/features/path/presentation/cubit/path_detail_cubit.dart` — carica `PathAreaDetail` via `PathRepository.fetchAreaSteps`
- `lib/features/path/data/path_repository_impl.dart:_mapAreaStepsDto` (riga 107-202) — costruisce ogni `PathTimeframeGroup` leggendo `isLocked`/`isCurrent` **direttamente dai flag del backend**, nessun calcolo lato client

Il punto chiave per tutti e tre i problemi: **il client non decide mai da solo se un mese o uno step è bloccato — legge solo `locked`/`is_current` così come arrivano dal backend.** Questo è confermato in [[path-feature-status]].

---

## Bug 1 — la lista mesi passati si blocca quando il mese corrente è completato

**Causa più probabile: bug/dato mancante lato backend, non lato client.**

Dalla memoria di progetto (sessione 2026-06-23): i campi autoritativi concordati col backend sono `timeframes[].locked`, `timeframes[].is_current`, `step.locked`, `step.is_current`, `access.percorso_locked`. Alla data di quella verifica **tutti questi flag arrivavano sempre `false`** nella risposta reale di staging (`GET /path/me/areas/{area}/steps`) — il client è stato scritto "tollerante" (nullable, fallback allo shape annidato in `step.timeframe`) proprio perché lo shape `timeframes[]`/`access` a livello top non era ancora popolato.

Ipotesi concreta per il comportamento riportato: quando un mese viene completato, il backend probabilmente ricalcola `is_current` spostandolo sul mese successivo, ma **non aggiorna correttamente `locked` sui mesi precedenti** (che dovrebbero restare sempre sbloccati una volta raggiunti/completati), oppure il mese completato smette di essere il "current" e finisce per essere trattato con la stessa logica del "non ancora raggiunto" → `locked: true`. Il client si limita a leggere quel flag (`path_repository_impl.dart:155` — `isLocked: timeframe.locked ?? false`), quindi se il backend manda `true` per un mese già completato, la UI lo mostra bloccato: coerente con "funziona se ci sono ancora moduli da fare" (mese ancora "current", `locked` correttamente `false`) e "si rompe a mese completato" (passaggio di stato che il backend gestisce male).

**Alternativa meno probabile ma da escludere:** il mese completato potrebbe sparire dall'array `steps` restituito per quella call — dato che la lista mesi lato client è costruita raggruppando `mainGroup.steps` per `step.timeframe.id` (`path_repository_impl.dart:119-131`), un mese senza step in risposta non comparirebbe affatto in lista (diverso da "bloccato", ma stesso sintomo percepito: "non riesco ad aprirlo").

**Come verificare (prima di scrivere codice):** chiamare `GET /path/me/areas/allenamento/steps` con un utente che ha completato il mese 1 e sta nel mese 2, e ispezionare i flag `locked`/`is_current` per il timeframe 1 nella risposta reale. Se `locked: true` su un mese già completato → conferma bug backend, si chiede fix diretto (un mese con `completed == total` non dovrebbe mai risultare `locked`). Se il timeframe manca proprio dall'array → problema di query/filtro lato backend.

**Nota:** questo non richiede nessuna modifica al client — il client già legge correttamente il flag; è il valore inviato che è sbagliato (o la regola "un mese completato è sempre navigabile" non è ancora implementata server-side).

---

## Bug 2 — messaggio generico invece che specifico su cosa manca

**Confermato: comportamento attuale come descritto, causa 100% lato client (testo statico).**

- Sheet: `lib/features/path/presentation/widgets/path_locked_sheets.dart:39-46` (`showTimeframeLockedSheet`) e `:48-93` (`_TimeframeLockedBody`) — **non prende nessun parametro**, quindi non può mostrare info dinamiche oggi.
- Stringhe attuali, `lib/l10n/app_it.arb`:
  - riga 88: `"pathTimeframeLockedTitle": "Mese bloccato"`
  - riga 89: `"pathTimeframeLockedBody": "Per sbloccare questo mese devi prima completare tutte le attività del mese precedente."`
  - equivalenti EN in `lib/l10n/app_en.arb:108-113`

Il testo attuale non è nemmeno quello riportato dall'utente ("devi completare gli esercizi precedenti") — è leggermente diverso ma stesso problema: generico, nessuna interpolazione.

**Cosa serve per il fix:**
1. **Testo esatto da Anna**, come richiesto esplicitamente dall'utente — placeholder proposto: *"Per sbloccare la sezione completa: {mancante} del mese corrente"* dove `{mancante}` è calcolato lato client da `completed`/`total` del mese corrente (già disponibili in `PathTimeframeGroup`, nessuna nuova chiamata backend richiesta) — es. "completa i 3 allenamenti rimanenti".
2. **Plumbing tecnico** (semplice, isolato lato client): passare il `PathTimeframeGroup` del mese corrente (o solo `completed`/`total`/`title`) a `showTimeframeLockedSheet`, che oggi non accetta parametri — serve aggiungere un parametro alla funzione e a `_TimeframeLockedBody`, e sostituire la stringa statica con una interpolata (`AppLocalizations` supporta placeholder ARB, pattern già usato altrove nel progetto per pluralizzazioni).
3. Nessuna dipendenza dal backend: i dati per calcolare "cosa manca" ci sono già nella risposta di `GET /path/me/areas/{area}/steps` che il client riceve oggi.

Va chiarito con Anna anche **quale mese riportare nel messaggio**: quello immediatamente precedente al mese cliccato, o sempre il "mese corrente" indipendentemente da quale mese futuro si è cliccato (es. se sono al mese 1 e clicco il mese 3, il messaggio deve parlare del mese 1 o del mese 2?). L'utente ha scritto "del mese corrente" quindi presumibilmente sempre il mese attivo, ma va confermato visto che con più mesi bloccati in sequenza il messaggio dovrebbe restare valido.

---

## Bug 3 — nessun blocco a livello di settimana all'interno del mese

**Confermato: funzionalità completamente assente, va costruita da zero.**

- Nessun concetto di "settimana" esiste nel dominio/dati/presentazione della feature `path`. L'unico livello di raggruppamento è il `timeframe` (mese); gli step dentro sono una lista piatta ordinata per `sort` (`path_repository_impl.dart:142`).
- "Settimana" oggi esiste solo come testo libero dentro ai titoli step (es. `"settimana 1 - allenamento 1"` nel sample `wiki/samples/path-area-steps-allenamento.json`), mai come dato strutturato.
- **Dato interessante non sfruttato:** `PathStepDto` porta già due flag granulari dal backend, parsati ma mai usati da nessuna parte del codice: `lockedByProgress` (`locked_by_progress`) e `lockedByRestricted` (`locked_by_restricted`) — `lib/features/path/data/dto/path_area_steps_dto.dart:221-227`. Non sono mappati nell'entità dominio (`PathStepItem` ha solo un `isLocked` bool piatto, `path_area_detail.dart:173`) e non sono letti da `path_step_screen.dart` (che controlla solo `!step.isLocked`, riga 253). Questo è quasi certamente l'aggancio che il backend ha già predisposto per un blocco "per motivo di progressione" più granulare del semplice mese — probabile candidato anche per il blocco settimanale.

**Cosa serve prima di implementare (domande per backend/Anna):**
1. Il backend ha già, o prevede di avere, un concetto di "settimana" strutturato (non solo testo nel titolo)? Se sì, che campo/shape avrà negli step? `lockedByProgress` è già pensato per questo caso d'uso?
2. Qual è la regola esatta di sblocco settimanale — "passa un tot di giorni fissi dall'inizio mese" o "passa tempo dal completamento della settimana precedente" o altro? L'utente scrive solo "finché non passa il tempo", serve la regola precisa (quanti giorni, calcolata come).
3. Il calcolo va fatto lato backend (stesso pattern di `locked` mensile, coerente con l'architettura attuale) o si aspetta che il client lo derivi da date/timestamp? Dato che tutta la logica di lock esistente è delegata al backend, la strada coerente è chiedere anche qui un flag pronto (es. estendere `locked`/`locked_by_progress` a livello di singolo step con semantica "settimana non ancora sbloccata"), evitando di duplicare regole di business nel client.

**CTA alternativa "guarda contenuti extra":** target già esistente e wired, non richiede nuova UI di destinazione:
- Sezione "Materiali extra" — `lib/features/path/presentation/path_materials_screen.dart`, cubit `path_materials_cubit.dart`
- Route: `/path/{area}/materials/{materialsGroupId}` (`lib/app/router.dart`), già linkata da `PathMaterialsRow` in `path_area_detail_screen.dart:219-230`
- Basta aggiungere, nella nuova sheet di blocco settimanale, un CTA che chiama `context.push('/path/${data.area}/materials/${data.materialsGroupId}')` — stesso pattern già in uso, nessun nuovo endpoint o schermata da creare.

---

## Riepilogo azioni

| # | Causa | Blocco su | Prossimo passo |
|---|---|---|---|
| 1 | Dato backend probabilmente errato (`locked` non ricalcolato bene a mese completato) | Verifica su staging + eventuale fix backend | Chiamare l'endpoint reale con utente a mese completato e ispezionare i flag; girare la questione a Daniele/backend |
| 2 | Testo statico lato client, nessun plumbing per dati dinamici | Testo esatto da Anna + conferma su "quale mese" citare | Chiedere copy ad Anna, poi piccola modifica client (parametro alla sheet + placeholder ARB) — nessuna dipendenza backend |
| 3 | Funzionalità assente, nessun dato strutturato di "settimana" | Design regola di sblocco + shape dati dal backend | Girare le 3 domande sopra a backend; la CTA "contenuti extra" è già pronta e riusabile una volta definita la regola |
