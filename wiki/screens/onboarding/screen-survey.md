# Screen — Survey (Initial & Final)

Onboarding questionnaire and proof-of-purchase flow. Sources:
`wiki/flow-screen/survey-iniziale.png` (frame "Survey iniziale") and
`wiki/flow-screen/prova-acquisto-iniziale.png` (frame "ins. Prova acquisto + Survey finale").

## Purpose

Profile the user before they enter the program. Collects answers (preset and free-text),
shows informational texts, validates a **proof-of-purchase** code, and returns a recommended
**kit / biotype**. Reached after first [[screen-login]]; leads into [[screen-home]] /
[[screen-path]].

## Flow & screen types

| Screen type | Description |
|-------------|-------------|
| Preset answer (Risposta preimpostata) | Single/multi choice question with predefined options |
| Free answer (Risposta libera) | Open text input |
| Informational text (Testo informativo) | Explanatory copy between questions |
| Kit result (Risultato kit) | Recommended kit/biotype outcome |
| Intermezzo | Brand-gradient interstitial with the meditating figure |
| Proof of purchase (Inserisci prova d'acquisto) | Code input ("Inserisci il codice") to validate an existing purchase |
| Final survey (Survey finale) | Nutrition-style questions (e.g. "Che tipo di alimentazione segui di solito?") |
| Platform intro (Intro piattaforma) | Closing informational screen before entering the app |

> Design note (from Figma): *"Frammentare concetti dove possibile. Sulle app evitare scroll più
> possibile"* — keep each step short, avoid long scrolling.

## Data / API

- Survey questions/answers and proof-of-purchase validation are **not documented** — see
  [[missing-apis]] (§1).
- The proof-of-purchase code links the **external e-commerce purchase** ([[cart]] / [[orders]])
  to program access; there is **no in-app checkout** — see [[missing-informations]].

## Implementation notes

- Feature placement: `features/survey/presentation/` (or `onboarding`).
- Persist progress so the flow can resume.

## Routing

`/survey/initial` → `/proof-of-purchase` → `/survey/final` → `/home`.

## Related

- [[screen-login]]
- [[screen-onboarding]]
- [[screen-home]]
- [[missing-apis]]
- [[missing-informations]]
- [[README]]
