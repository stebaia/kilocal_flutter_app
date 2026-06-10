# Screen — Onboarding (Sales Speech)

Post-splash onboarding carousel ("Approdo sales speech"). Source: Figma flow
`wiki/flow-screen/splash.png` (frame "SPLASH + APPRODO SALES SPEECH").
Follows [[screen-splash]]. Tokens from [[design-system]].

## Purpose

Introduce the program right after the splash, before login/registration. A multi-step
("N STEP") carousel on the brand gradient background presents value/benefit slides, then leads
the user into [[screen-login]] and the [[screen-survey]] flow.

## Layout

Full-bleed brand gradient (pink→crimson) with the 3D meditating figure illustration at the top,
text block below, page indicator dots, and a forward/start control.

| Element | Description |
|---------|-------------|
| Background | Vertical `brandGradient` (see [[design-system]]) |
| Illustration | 3D meditating figure (same asset as [[screen-splash]]) |
| Title | Step title (e.g. "Lorem Ipsum", "Inizia a lorem ipsum") |
| Body | Short descriptive paragraph |
| Page indicator | Dots showing current step out of N |
| CTA | Next / arrow control; final step shows a "Start"/primary button |

## Behavior

- Swipe or tap the forward control to move between steps.
- The last step routes onward to [[screen-login]] (login / sign up).

## Data / API

- Slides may be static (bundled) or CMS-driven. No documented endpoint yet — see
  [[missing-apis]].

## Implementation notes

- `SystemUiOverlayStyle.light` over the dark brand background (as in [[screen-splash]]).
- Feature placement: `features/onboarding/presentation/`.
- Strings are localized (default Italian per project i18n).

## Routing

`/splash` → `/onboarding` → `/login`. Skip onboarding on subsequent launches if already seen
(persist a flag).

## Related

- [[screen-splash]]
- [[screen-login]]
- [[screen-survey]]
- [[design-system]]
- [[flutter-architecture]]
- [[README]]
