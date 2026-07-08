# Survey — domande al backend (RISOLTE)

> **Stato: chiuso.** Tutte e 6 le domande sono state **confermate dal backend**
> (con una fixture reale di submit) e recepite in `buildSubmitBody`
> (`survey_mapper.dart`), con test di regressione in
> `survey_submit_body_test.dart`. Il contratto finale è documentato in
> [[survey]] → sezione "Submit contract — confermato dal backend". Questo file è
> conservato solo come storico del messaggio originale.

Messaggio human-friendly (storico) inoltrato a chi gestisce il backend per
sbloccare il **submit** della survey. La parte di lettura domande (GraphQL) era
già integrata e verificata — vedi [[survey]].

---

## Versione chat / Slack (breve)

> Ciao! Sto integrando la survey lato app (iniziale + finale). La parte di
> **lettura** delle domande da GraphQL è a posto, mi mancano solo un po' di
> conferme su come mandarvi le risposte con `POST /survey/submit/{internalName}`.
> Sono 6 punti veloci:
>
> 1. **Come vi passo le risposte in `steps`?** Uso l'ID della sezione come chiave,
>    giusto? (es. `steps: { "14": {...} }`). E in `storeToField` ci va il nome
>    campo di `user_details` (es. `gender`, `height`)?
>
> 2. **Formato della singola risposta:** per le domande a scelta (radio/checkbox)
>    vi mando `{ id, value_to_store }` dell'opzione scelta — va bene? E per i campi
>    liberi/numerici e la data di nascita, in che formato la data?
>    (`2026-07-02`?)
>
> 3. **BMI:** lo calcolo io lato app da altezza/peso e ve lo mando. Confermate la
>    formula standard (peso / altezza²) e lo volete come numero (es. `24.2`) o
>    stringa?
>
> 4. **Età:** la ricavo dalla data di nascita e ve la mando in `ageValue` come
>    numero di anni interi — ok?
>
> 5. **Schermata risultato ("sei un Tipo 4 - Pera" + kit):** i dati per quella
>    schermata (nome tipo, immagine kit, descrizione, link acquisto) me li tornate
>    tutti nella risposta del submit dentro `outcome`, o devo rileggerli da
>    un'altra parte?
>
> 6. **Quando mostro quale survey?** Mi baso su `profile_status` da
>    `/survey/me/status`: `initial_survey` → `type_survey`, poi `starter_kit`, ecc.
>    Me lo confermate? E per i flussi farmacia/prodotto singolo, cosa devo mettere
>    in `pharmacy_data` / `single_product_id`?
>
> Anche solo un esempio di JSON di submit "buono" mi sblocca tutto 🙏

---

## Versione mail (un filo più strutturata)

> Oggetto: **App – conferme sul submit della survey**
>
> Ciao,
> sto collegando la survey nell'app. Leggo già le domande da GraphQL senza
> problemi; mi servono solo alcune conferme su come inviarvi le risposte
> (`POST /survey/submit/{internalName}`), così evito di fare assunzioni sbagliate.
>
> **1. Struttura `steps`** — Uso l'ID della sezione come chiave della mappa e in
> `storeToField` il campo di `user_details` (gender, height, weight,
> date_of_birth…). Confermate?
>
> **2. Formato risposta** — Scelta singola/multipla: mando l'opzione come
> `{ id, value_to_store }` (e per l'opzione "Altro" aggiungo il testo libero).
> Campi liberi/numerici: valore grezzo. Data di nascita: che formato preferite
> (es. `2026-07-02`)?
>
> **3. BMI** — Lo calcolo lato app (peso in kg / altezza in m²). Va bene come
> numero con un decimale, o lo volete stringa?
>
> **4. Età** — La derivo dalla data di nascita e la invio in `ageValue` (anni
> interi). Ok?
>
> **5. Schermata risultato** (biotipo + kit consigliato) — I dati da mostrare
> (nome tipo, immagine, testo, link kit) arrivano tutti nella risposta del submit
> (`outcome` / `kit_shop_url`), o vanno letti da un'altra collection?
>
> **6. Ordine dei flussi** — Mi regolo su `profile_status` per decidere quale
> survey aprire (initial → type_survey, poi starter_kit, ecc.). Confermate la
> logica? E per farmacia / prodotto singolo, cosa vi devo passare in
> `pharmacy_data` e `single_product_id`?
>
> Se avete un **esempio reale di body di submit** già validato, quello da solo
> risponde a quasi tutto.
> Grazie!

---

## Related

- [[survey]] — schema verificato + sezione tecnica "Domande aperte al backend"
- [[profilo-read]]
