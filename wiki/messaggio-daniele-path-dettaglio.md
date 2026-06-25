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

**3. Dati sporchi in alcuni `vimeo_url` (allenamento).**
Alcuni step hanno `vimeo_url` non validi, che romperanno il player. Esempi reali:
- step id 3 → `vimeo_url: "settimana 2 - allenamento 1"` (è un titolo, non un URL)
- step id 89 → `vimeo_url: "https://vimeo.com/manage/videos/1120784321"` (link di *gestione*, non
  l'embed pubblico)
Potete bonificarli sul CMS? Per il resto il formato `https://vimeo.com/<id>?...` lo gestisco già.

Grazie!
