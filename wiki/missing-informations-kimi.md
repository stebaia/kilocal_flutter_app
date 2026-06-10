# Informazioni Mancanti e Problematiche — Analisi Figma vs Wiki API

> Analisi effettuata confrontando tutti gli screen del flow Figma (`wiki/flow-screen/`) con la documentazione API presente nei file markdown di `wiki/` e con l'architettura Flutter definita in `flutter-architecture.md`.

---

## 🔴 Problema Fondamentale: L'app Figma e le API documentate sono due mondi diversi

Le API attualmente documentate nella wiki descrivono un **backend e-commerce** (carrello, ordini, PayPal, indirizzi, catalogo prodotti).  
L'app mostrata nel flow Figma è un'app **wellness / lifestyle** (percorsi, allenamento, alimentazione, benessere, integrazione, diario, traguardi, statistiche, survey) con una **sezione shop secondaria** integrata nel profilo.

**Implicazione**: la maggior parte degli screen Figma non ha alcun endpoint documentato nella wiki. L'architettura Flutter (`flutter-architecture.md`) è stata progettata per un e-commerce, ma l'app che deve essere realizzata è un'app wellness con e-commerce incorporato. L'architettura va rivista o estesa per coprire i domain mancanti.

---

## 🔴 Screen presenti in Figma ma TOTALMENTE assenti dalla wiki

Di seguito tutti gli screen o gruppi di screen per i quali non esiste alcun file `.md` che documenti le relative API, entità, DTO o comportamento backend.

### 1. Onboarding / Splash (`splash.png`)
- **Cosa mostra**: N-step introduttivi con illustrazioni, titoli e descrizioni
- **Cosa manca**: API per contenuti dinamici dell'onboarding (slide, testi, immagini), logica di "primo avvio" vs "avvio successivo", endpoint per persistere lo stato di onboarding completato

### 2. Survey iniziale (`survey-iniziale.png`)
- **Cosa mostra**: Questionario multi-step con domande su:
  - Altezza (risposta libera numerica)
  - Obiettivo principale (risposta predefinita: perdere peso, digerire meglio, smaltire liquidi, etc.)
  - Valutazione assunzione prodotti Kilocal (scale 1-5)
  - Risultato: "Tipo X — Pera", starter kit consigliato
- **Cosa manca**:
  - Endpoint per salvare le risposte della survey
  - Endpoint per calcolare il "tipo corporeo" in base alle risposte
  - Endpoint per associare un kit / percorso all'utente in base al risultato
  - Documentazione del data model della survey (domande, opzioni, logica di scoring)

### 3. Prova acquisto iniziale (`prova-acquisto-iniziale.png`)
- **Cosa mostra**: Inserimento codice scontrino (prova d'acquisto), verifica validità, survey finale su alimentazione, accesso alla piattaforma
- **Cosa manca**:
  - Endpoint per verificare/validare un codice scontrino
  - Endpoint per salvare la survey finale
  - Logica di abilitazione account dopo prova d'acquisto

### 4. Home Dashboard (`hero-home.png`)
- **Cosa mostra**:
  - Hero con contenuti personalizzati ("Continua il percorso", "Frase motivazionale", "È ora del pasto", etc.)
  - Progressi ("Mese 1", "80%")
  - Sezioni "Momenti" e "Benefit"
- **Cosa manca**:
  - API per contenuti dinamici della home (hero, consigli personalizzati)
  - API per progressi utente (percentuale completamento, mese corrente)
  - Nessuna documentazione sul come il backend determina quali card mostrare

### 5. Notifiche (`notifiche.png`)
- **Cosa mostra**: Lista notifiche push/in-app con filtri (Tutte, Categoria, Archiviate), tipologie diverse (testo, con immagine, con bottone)
- **Cosa manca**:
  - Endpoint per recuperare notifiche utente
  - Endpoint per archiviare/segna come letta
  - Endpoint per preferenze notifiche push
  - Data model notifica (title, body, image, action, category, read status)

### 6. Momenti (`momenti.png`)
- **Cosa mostra**: Dettaglio "Momenti" (challenge giornaliere a 7 giorni)
- **Cosa manca**:
  - API per lista momenti / challenge
  - API per completamento giornaliero
  - Data model momento (titolo, descrizione, meccanica, giorni, stato)

### 7. Statistiche (`statistiche.png`)
- **Cosa mostra**: Statistiche mese corrente suddivise per:
  - Allenamento (X/Y attività)
  - Alimentazione (X/Y attività)
  - Benessere (X/Y attività)
  - Integrazione (X/Y attività — "Fase 1")
- **Cosa manca**:
  - Endpoint per recuperare statistiche di completamento
  - API per aggregare attività completate per categoria e mese/fase
  - Data model statistiche (categoria, periodo, completate, totali, percentuale)

### 8. Percorso — Allenamento (`percorso2.png`)
- **Cosa mostra**:
  - Hub allenamento (mesi, progressi, materiali extra)
  - Dettaglio esercizio con video, descrizione, timer
  - Lista attività con check/lock
  - Timer con ore/minuti/secondi
- **Cosa manca**:
  - API per struttura percorso allenamento (mesi, settimane, giorni, esercizi)
  - API per contenuti esercizio (video URL, descrizione, durata)
  - API per tracciamento completamento attività
  - API per timer / impostazione promemoria
  - Data model: percorso → mese → settimana → giorno → esercizio

### 9. Percorso — Alimentazione (`percorso3.png`, `percorso6.png`)
- **Cosa mostra**:
  - Hub alimentazione con mesi
  - Dettaglio ricetta / step alimentari
  - Materiali extra (categorie, filtri)
- **Cosa manca**:
  - API per piano alimentare (ricette, step, consigli)
  - API per materiali extra (documenti, guide, contenuti scaricabili)
  - Data model contenuto alimentare

### 10. Percorso — Benessere (`percorso4.png`)
- **Cosa mostra**: Hub benessere (Mindfulness, Self care, Stili di vita), dettaglio con mesi
- **Cosa manca**:
  - API per contenuti benessere
  - API per categorie benessere e sotto-categorie

### 11. Percorso — Integrazione (`percorso5.png`)
- **Cosa mostra**:
  - Fasi integrazione (Fase 1, Fase 2)
  - Dettaglio prodotto (Kilocal SlimCell)
  - Promemoria assunzione (orario, posticipa, attiva)
  - Istruzioni d'uso, date inizio/fine
- **Cosa manca**:
  - API per fasi integrazione associate all'utente
  - API per promemoria integratore (CRUD promemoria: orario, ripetizione, posticipo)
  - API per "Segna come preso" / stato assunzione
  - Data model promemoria (prodotto, orario, giorni, stato, notifiche)

### 12. Diario — Cronologia (`diario1.png`)
- **Cosa mostra**: Diario attività giornaliere con cronologia, filtri, dettaglio attività
- **Cosa manca**:
  - API per lista attività del diario
  - API per completamento attività ("Segna come completata")
  - API per dettaglio attività (categoria, data, promemoria collegato)
  - API per filtri diario (cronologia completa, completate, in ritardo, posticipate)

### 13. Diario — Traguardi (`diario2.png`)
- **Cosa mostra**:
  - Lista traguardi personali e Kilocal
  - Dettaglio traguardo (completa, modifica, elimina)
  - Crea traguardo personale (testo, data, orario, categoria)
- **Cosa manca**:
  - API per traguardi (CRUD completo)
  - API per categorie traguardo
  - Data model traguardo (titolo, descrizione, data target, categoria, stato, tipo)

### 14. Profilo — Tipo corporeo / Caratteristiche (`profilo1.png`, `profilo3.png`)
- **Cosa mostra**: Schermata "Le tue caratteristiche" con silhouette del corpo, punti di interesse, 7 tipi diversi (Tipo 1-7), descrizioni per ogni zona corporea
- **Cosa manca**:
  - API per recuperare il tipo corporeo calcolato
  - API per descrizioni / contenuti per tipo
  - Data model tipo corporeo e caratteristiche

### 15. Profilo — Preferenze alimentari / Notifiche push / Assistenza / Privacy (`profilo1.png`)
- **Cosa mostra**:
  - Toggle notifiche push
  - Preferenze alimentari
  - Tutorial, Contatta assistenza, Valuta app, Privacy, Termini, Versione
- **Cosa manca**:
  - API per salvare/recuperare preferenze utente (notifiche, alimentari)
  - API per invio richiesta assistenza
  - API per informativa privacy / termini (anche se potrebbero essere contenuti CMS statici)

---

## 🟠 Feature parzialmente coperte ma incomplete

### Registrazione / Profilo utente
- `users.md` documenta registrazione (`POST /api/users`) e password reset
- **Cosa manca**:
  - Endpoint per **modifica dati personali** (nome, cognome, email, password da utente loggato)
  - Endpoint per **eliminazione account**
  - Endpoint per **modifica email** (con conferma)
  - Endpoint per **upload immagine profilo**
  - Il Figma mostra "Il mio account" come sezione profilo, ma non c'è documentazione su come gestirlo

### Indirizzi
- `user-addresses.md` copre CRUD indirizzi
- **Cosa manca**: nel Figma non c'è nessuno screen per la gestione indirizzi. Gli indirizzi appaiono solo implicitamente nel checkout (che però non ha screen nel Figma analizzato).

### Carrello / Ordini / PayPal
- Documentati in `cart.md`, `orders.md`, `paypal.md`
- **Cosa manca nel Figma**: nessuno screen del flow analizzato mostra il carrello, la lista prodotti, il checkout, o la conferma ordine. Questi screen potrebbero esistere in un altro file Figma non presente in `wiki/flow-screen/`.
- **Nota**: in `profilo2.png` compare il pulsante "Acquista" su un prodotto (Kit tipo 4), il che conferma che l'e-commerce esiste ma i relativi screen di catalogo/carrello/checkout **non sono inclusi** nel flow-screen fornito.

### Settings
- `settings.md` documenta `GET /api/settings` per menu, footer, generic strings
- **Cosa manca**: nel Figma le "settings" appaiono come menu utente nel profilo, non come schermata dedicata. L'endpoint `/api/settings` sembra più orientato al frontend web (menu, footer) che all'app mobile.

---

## 🟡 Problematiche architetturali derivanti

### Architettura Flutter non allineata all'app reale
`flutter-architecture.md` definisce i feature:
- `auth`, `settings`, `cart`, `orders`, `checkout`, `addresses`, `catalog`

**Feature mancanti nell'architettura** (tutte presenti in Figma):
- `onboarding`
- `survey`
- `home` (dashboard contenuti personalizzati)
- `percorso` / `pathway` (allenamento, alimentazione, benessere, integrazione)
- `diario` / `journal` (cronologia, attività)
- `traguardi` / `goals`
- `momenti` / `challenges`
- `statistiche` / `statistics`
- `notifiche` / `notifications`
- `benefit` / `rewards`
- `profile` (gestione dati, tipo corporeo, preferenze)
- `promemoria` / `reminders` (integratori)

### CMS Proxy — Contenuti dinamici
L'architettura mappa il catalogo su `POST /cms/graphql` ma non c'è documentazione su:
- Quali collection Directus contengono i contenuti wellness (percorsi, esercizi, ricette, articoli benessere)
- Schema GraphQL per questi contenuti
- Relazioni tra entità (es. percorso → mese → settimana → giorno → esercizio)

---

## ✅ Cosa è corretto e allineato

- **Autenticazione**: Login/registrazione in Figma corrisponde a `authentication.md` + `users.md`
- **Struttura bottom nav**: 5 tab (Home, Percorso, Diario, Benefit, Profilo) — coerente in tutti gli screen
- **Shop integrato**: Il profilo mostra "Kit" e "Integrazione e prodotti" con pulsante "Acquista", coerente con l'esistenza delle API e-commerce

---

## 📋 Riassunto azioni necessarie

Per rendere la wiki completa e l'architettura Flutter implementabile, servono:

1. **Documentare TUTTE le API wellness** mancanti (survey, percorsi, diario, traguardi, statistiche, notifiche, promemoria, benefit)
2. **Aggiornare `flutter-architecture.md`** aggiungendo i feature mancanti e il loro mapping alle API
3. **Definire lo schema GraphQL / CMS** per i contenuti editoriali (percorsi, esercizi, ricette, articoli)
4. **Documentare il data model** per survey, tipo corporeo, progressi utente, promemoria, traguardi
5. **Completare il profilo utente** con endpoint per modifica dati, upload avatar, eliminazione account
6. **Verificare** se esistono altri file Figma con gli screen dello shop (catalogo, carrello, checkout) da aggiungere a `wiki/flow-screen/`
