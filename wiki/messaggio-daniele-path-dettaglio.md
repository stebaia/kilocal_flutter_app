# Messaggio per Daniele — dettaglio area Percorso

> Bozza pronta da incollare in chat. Riguarda `GET /path/me/areas/{area}/steps`.

---

Ciao Daniele! Ho montato la schermata di dettaglio area seguendo il Figma e mi servono un paio di
cose in più sull'endpoint `/path/me/areas/{area}/steps`, più una segnalazione su dei dati sporchi.

**1. Sottotitolo/descrizione del timeframe (mese).**
Nel Figma ogni riga "mese" ha una riga descrittiva sotto il titolo (es. "Primo mese — Semplici
esercizi per carburare", "Secondo mese — Esercizi intermedi per il corpo"). Oggi sul `timeframe`
ho solo `translations[].title` ("1° mese"). Per ora ho messo come sottotitolo il numero di attività,
ma se aveste una **descrizione localizzata sul timeframe** la userei. Ce la potete aggiungere?

**2. Stato "bloccato" del mese. ✅ RISPOSTO (2026-06-23).**
~~Sempre nel Figma i mesi futuri (2°/3°) appaiono **bloccati** (lucchetto, grigio). A livello di step
ho `locked`, ma nei dati reali è sempre `false`, quindi non riesco a capire quali timeframe mostrare
come bloccati. Mi servirebbe o un `locked`/`unlocked` **a livello di timeframe**, oppure la regola
ufficiale. Come preferite gestirlo?~~

> Risposta backend — i flag autoritativi sono:
> - Lucchetto sul mese → `timeframes[].locked`
> - Mese attivo → `timeframes[].is_current`
> - Lucchetto sullo step → `step.locked`
> - Step attivo → `step.is_current`
> - Area intera bloccata → `access.percorso_locked`
>
> Cablato lato client (DTO/domain/repo tolleranti). ⚠️ Da verificare: nel sample di staging del
> 23/06 `timeframes[]` top-level e `access` non arrivavano ancora — confermare quando il nuovo
> shape è pubblicato.

**3. Descrizione/contenuto dello step.**
La schermata di dettaglio del singolo step (Figma) ha sotto il titolo un **paragrafo descrittivo
lungo** ("Scopri come migliorare il tuo benessere…"). Oggi sull'endpoint
`/path/me/areas/{area}/steps` lo step ha solo `translations[].title` (es. "settimana 1 -
allenamento 1"). Mi serve un campo localizzato `description`/`content` dentro `step.translations`:
l'ho già predisposto lato client (nullable: appena lo popolate compare da solo, nel frattempo lo
slot resta vuoto). La **durata del video** invece la ricavo da solo via Vimeo oEmbed (pubblico),
quindi su quella non serve nulla — a meno che preferiate esporla voi sull'`asset` per evitare la
chiamata extra.

**4. Schermata step "ricca" (bottom sheet Attività + Timer) — dati che derivo client-side.**
Ho implementato la schermata step completa come da Figma: player 417px, icona "Attività" in alto a
destra (bottom sheet con la lista degli step del mese), e le due icone Timer in basso a sinistra
(picker ore/min/sec + countdown). Note su cosa è derivato vs cosa manca:
- **Durata di ogni step** nella lista Attività → da Vimeo oEmbed (una chiamata per step). Funziona ma
  è un po' di latenza per liste lunghe; se aveste la durata sull'`asset` la userei direttamente.
- **Percentuale per-step** (nel Figma una card mostra "12%") → **non derivabile**: lo stato di uno
  step è binario (`completed` true/false), non c'è avanzamento parziale. Per ora mostro
  completato/in corso/bloccato senza percentuale. Se serve la % per-step ci vuole un campo dedicato.
- Il **Timer** è puramente lato client (nessun dato backend), quindi è completo.

**5. Dati sporchi in alcuni `vimeo_url` (allenamento).**
Alcuni step hanno `vimeo_url` non validi, che romperanno il player. Esempi reali:
- step id 3 → `vimeo_url: "settimana 2 - allenamento 1"` (è un titolo, non un URL)
- step id 89 → `vimeo_url: "https://vimeo.com/manage/videos/1120784321"` (link di *gestione*, non
  l'embed pubblico)
Potete bonificarli sul CMS? Per il resto il formato `https://vimeo.com/<id>?...` lo gestisco già.

Grazie!
