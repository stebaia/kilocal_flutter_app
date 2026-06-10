# Screen — Splash

Entry / launch screen of the `kilocal_flutter_app`. Source: Figma node `3403:55821`
("Group 26085520") in **KILOCAL-PROGRAM** (`figma.com/design/wvV8JURTECntVCsHl5sNLc`).
Tokens come from [[design-system]].

## Purpose

Branded splash shown at app start while bootstrap work runs (load [[settings]], restore session
from [[authentication]]), then route onward via GoRouter ([[flutter-architecture]]).

## Layout (390 × 844)

Full-bleed brand background with a single centered illustration — no text, buttons, or inputs.

| Element | Description | Position (approx.) |
|---------|-------------|--------------------|
| Background | Vertical `brandGradient` (pink→crimson), full screen | fill |
| Top glow | Large soft pink ellipse (~1179px) anchored above the top edge | center, top `-235` |
| Illustration | 3D meditating figure (lotus pose): white body, coral top, black shorts | centered, top `~128`, `~339×339` |
| Shadow | Soft elliptical drop shadow beneath the figure | center, below illustration |

```
┌─────────────────────────┐
│  (soft pink glow)        │
│                          │
│          ◯               │  ← 3D figure, lotus / meditation pose
│         /│\              │
│        ( + )             │
│         ___              │
│        (___)  ← shadow   │
│                          │
│      pink → crimson      │
└─────────────────────────┘
```

## Implementation notes

- Background: `Container` with `BoxDecoration(gradient: brandGradient)` from [[design-system]];
  optional `RadialGradient` overlay for the top glow.
- Illustration: raster PNG asset (`assets/images/`), centered, ~87% screen width capped at the
  artboard ratio. Provide @2x/@3x. The drop shadow can be baked into the asset.
- No localized strings on this screen — nothing for the i18n pass (see project i18n notes).
- Mark `SystemUiOverlayStyle.light` (light status-bar icons over the dark brand background).
- Feature placement: `features/splash/presentation/` (presentation-only; logic delegated to the
  existing bootstrap blocs — `SettingsCubit`, `AuthBloc`).

## Routing

`/` (or `/splash`) as the initial GoRouter location → redirects to home or login once bootstrap
completes. Keep splash duration tied to real work, not a fixed timer.

## Related

- [[design-system]]
- [[flutter-architecture]]
- [[authentication]]
- [[settings]]
- [[README]]
