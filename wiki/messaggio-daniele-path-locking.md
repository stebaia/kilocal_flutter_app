# Messaggio per Daniele — blocco mesi/settimane Percorso

> Bozza pronta da incollare in chat. Segue il messaggio precedente su `GET /path/me/areas/{area}/steps`
> ([[messaggio-daniele-path-dettaglio]]) — qui il focus è sul comportamento del lock, segnalato da un
> utente reale in test.

---

Ciao Daniele! Un utente ci ha segnalato due problemi legati al blocco mesi/step nel Percorso
(Allenamento e Alimentazione), entrambi collegati ai flag `locked`/`is_current` di cui parlavamo.

**1. Un mese completato torna ad apparire bloccato.**

Comportamento riportato: l'utente riesce a navigare avanti/indietro tra i mesi finché ha ancora
attività da fare nel mese corrente. Appena **completa tutte le attività del mese corrente**, non
riesce più ad aprire i mesi **passati** (quelli già fatti in precedenza) dalla lista — la app si
comporta come se fossero bloccati.

Lato client noi leggiamo solo `timeframes[].locked` così come arriva dalla vostra risposta (nessun
calcolo nostro), quindi il sospetto è che quando un mese viene completato e `is_current` si sposta
al mese successivo, il ricalcolo di `locked` sui mesi **precedenti** non stia tornando `false` come
dovrebbe (un mese già completato dovrebbe restare sempre navigabile, indipendentemente da dove si
trova ora `is_current`).

Potete verificare la risposta di `GET /path/me/areas/{area}/steps` per un utente che ha appena
completato un mese, controllando in particolare il valore di `locked` sui timeframe precedenti in
quel momento? Se conferma che torna `true` (o comunque non `false`) è il bug da sistemare; se invece
i flag sono corretti lato vostro, fateci sapere lo shape esatto che vedete così confrontiamo con
quello che riceviamo noi — potrebbe anche essere che il timeframe sparisca proprio dall'array
`steps` in quella risposta, cosa che lato nostro produce lo stesso sintomo (mese non apribile).

**2. Manca il blocco a livello di settimana dentro il mese.**

Oggi, dentro un mese sbloccato, l'utente può fare tutte le attività di tutte le settimane in una
volta sola — non c'è alcun blocco progressivo. Ci hanno chiesto che il comportamento sia: fatta la
settimana 1, la settimana 2 resta bloccata finché non passa un certo periodo di tempo (con CTA
alternativa verso i contenuti extra, quello lo gestiamo noi lato app).

Lato dati oggi il concetto di "settimana" non esiste come campo strutturato — esiste solo come testo
libero dentro `step.translations.title` (es. "settimana 1 - allenamento 1"), quindi non possiamo
implementare nessun blocco a meno di parsare il titolo, cosa che vogliamo evitare.

Abbiamo notato che lo step ha già due campi che non stiamo ancora usando:
`step.locked_by_progress` e `step.locked_by_restricted`. Erano pensati proprio per un caso come
questo?

Ci servirebbe sapere:
- Esiste già, o è prevista, una struttura "settimana" sui dati dello step (numero settimana, o un
  raggruppamento simile al `timeframe` ma più granulare)?
- Qual è la regola di sblocco che avete in mente — un numero fisso di giorni dall'inizio del mese, o
  un numero di giorni dal completamento della settimana precedente, o altro? Ci serve la regola
  esatta per capire se needs anche una data "sbloccato a partire da" nella risposta.
- Preferite calcolare voi il flag di blocco (stesso pattern di `timeframes[].locked`/`step.locked`
  che avete già, così restiamo coerenti con l'architettura attuale — noi leggiamo solo i flag, non
  facciamo mai calcoli di data/regole di business lato client), oppure preferite che sia il client a
  derivarlo da un timestamp che ci passate voi (es. `unlocks_at` sullo step)?

Grazie!
