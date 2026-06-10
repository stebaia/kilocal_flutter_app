# Design System

Visual design tokens for the `kilocal_flutter_app`, derived from the Figma design
**KILOCAL-PROGRAM** (`figma.com/design/wvV8JURTECntVCsHl5sNLc`). These feed the Flutter
`ThemeData` in `core/theme/` (see [[flutter-architecture]]).

> Source frame is a 390×844 mobile artboard (logical iPhone-class size). Treat values as
> density-independent points and let Flutter scale across devices.

## Brand colors

The brand identity is a warm crimson/raspberry gradient with coral and neutral accents from
the brand illustrations.

| Token | Hex | Usage |
|-------|-----|-------|
| `brandPink` | `#ED1A4B` (approx.) | Gradient start (top), primary brand surface |
| `brandCrimson` | `#C9143C` (approx.) | Gradient end (bottom), deeper brand surface |
| `coral` | `#FF5A5A` (approx.) | Illustration accent (sports top); use sparingly as a highlight |
| `neutralWhite` | `#FFFFFF` | Foreground on brand surfaces (text, logo, icons) |
| `ink` | `#1A1A1A` (approx.) | Illustration dark accent; default text on light surfaces |

> Hex values are sampled from the rendered Figma node — no bound color **variables** exist on
> the splash node yet (`get_variable_defs` returned empty). Confirm exact brand hexes with the
> design team / a proper variables export before locking them into the theme.

### Light-surface palette (in-app screens)

The program app ([[screen-home]], [[screen-path]], [[screen-statistics]], …) runs on a **light
theme**: light-grey background, white cards, dark text, with brand red as the single accent.
Sampled from `wiki/flow-screen/statistiche.png` and `momenti.png` — **approximate, confirm**.

| Token | Hex (approx.) | Usage |
|-------|---------------|-------|
| `background` | `#F4F4F6` | App scaffold background (light grey) |
| `surface` | `#FFFFFF` | Cards, sheets, app bar |
| `accent` | `#E51E4D` | Primary accent (brand red): active icons, progress, key numbers, CTAs |
| `accentSoft` | `#FCE7EC` | Tinted background behind the active bottom-bar icon, subtle highlights |
| `textPrimary` | `#1A1A1A` | Titles, body text on light surfaces (= `ink`) |
| `textSecondary` | `#6B6B72` | Labels, captions, metadata (e.g. "Mese 1") |
| `divider` | `#ECECEF` | Hairline dividers, card borders |

> Two themes coexist: the **brand-gradient** theme (splash/onboarding, see [[screen-splash]],
> [[screen-onboarding]]) and this **light** theme (the rest of the app). Model both in
> `ThemeData` (or a single theme + a branded gradient background widget).

## Gradient

The signature brand background is a vertical (top→bottom) gradient used full-bleed behind
illustration screens such as the splash ([[screen-splash]]).

```dart
const brandGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFFED1A4B), Color(0xFFC9143C)],
);
```

The splash also overlays a large soft radial ellipse (lighter pink, ~1179px, anchored above the
top edge) to brighten the upper area — model as an optional `RadialGradient` overlay rather than
a separate asset if reproducing in code.

## Imagery

- 3D brand illustrations (e.g. the meditating figure on the splash) are **raster assets**, not
  vectors. Export from Figma as transparent PNGs (provide @1x/@2x/@3x) into `assets/images/`.
- Soft drop-shadow ellipse beneath floating figures is part of the illustration treatment; bake
  it into the asset or recreate with a blurred `Container`.

## Typography

Single sans-serif family across the app (geometric/grotesque; final family **to confirm** with
the design team — likely Inter / SF Pro / similar). Scale inferred from in-app screens
(`statistiche.png`, `momenti.png`) — **sizes approximate**.

| Style | Size / Weight | Usage |
|-------|---------------|-------|
| `headlineLarge` | ~22sp / SemiBold | Screen content title (e.g. "Lorem ipsimd dpawojd") |
| `titleLarge` | ~18sp / SemiBold | App-bar title ("Statistiche mese corrente", "Momenti") |
| `titleMedium` | ~16sp / SemiBold | Card title ("Allenamento", "Meccanica:") |
| `bodyMedium` | ~14sp / Regular | Paragraph / body copy |
| `labelMedium` | ~13sp / Medium | Secondary labels ("Mese 1") — `textSecondary` |
| `numericAccent` | ~16–18sp / Bold | Emphasized values in accent red ("3/15 attività", "80%") |

- Default text color `textPrimary`; secondary/meta uses `textSecondary`; emphasized
  values/links use `accent`.

## Layout & spacing

- Reference artboard: **390 × 844**.
- Illustration on the splash sits centered horizontally, ~128pt from the top, ~339pt square.

4pt-based spacing scale (use these as named constants in `core/theme/`):

| Token | Value | Usage |
|-------|-------|-------|
| `space2xs` | 4 | Icon ↔ label gaps |
| `spaceXs` | 8 | Tight inner padding |
| `spaceSm` | 12 | Inter-element spacing inside cards |
| `spaceMd` | 16 | **Screen horizontal padding**, default card padding |
| `spaceLg` | 24 | Section spacing |
| `spaceXl` | 32 | Large vertical rhythm between blocks |

- Screen content gutter: **16pt** left/right.
- Vertical gap between stacked cards: **~12–16pt**.

## Shape & radius

| Token | Value (approx.) | Usage |
|-------|-----------------|-------|
| `radiusSm` | 8 | Chips, small controls |
| `radiusMd` | 12 | Buttons, inputs |
| `radiusLg` | 16 | **Cards**, sheets, hero banners |
| `radiusPill` | 999 | Pill buttons, badges |

## Elevation & shadow

Cards on the light theme use a single soft shadow; everything else is flat.

| Token | Spec (approx.) | Usage |
|-------|----------------|-------|
| `cardShadow` | y+4, blur 16, `#000000` @ ~6% opacity | White cards on light background |
| `barShadow` | y-2, blur 12, `#000000` @ ~4% opacity | Bottom navigation bar top edge |

```dart
const cardShadow = [
  BoxShadow(color: Color(0x0F000000), blurRadius: 16, offset: Offset(0, 4)),
];
```

## Components

### Card
- `surface` white, `radiusLg` (16), `cardShadow`, padding `spaceMd` (16).
- Optional leading icon + title (`titleMedium`), supporting label (`labelMedium`,
  `textSecondary`), and a trailing element (e.g. circular progress).

### Circular progress
- Ring in `accent` over a light track, percentage label centered (`numericAccent`).
- Used on [[screen-home]] (overall progress) and [[screen-statistics]] (per-area). Build once as
  a reusable widget.

### Buttons
- **Primary:** filled `accent`, white text, `radiusPill` or `radiusMd`, full-width in flows.
- **Secondary/ghost:** outlined or text-only in `accent`.

### App bar
- `surface` background, flat, leading back chevron, centered/leading `titleLarge`, optional
  trailing icon (info/calendar).

### Bottom navigation bar
- 5 tabs on a white `surface` bar with `barShadow`; see [[navigation]] for the tab → screen map.
- **Active** tab: brand `accent` icon on an `accentSoft` rounded highlight; **inactive**:
  `textSecondary` line icons. Typically icon-only (no labels).

## Open items / to confirm

- Exact font **family** and precise type sizes/line-heights.
- Exact light-theme **hex** values and the brand red used in-app (`accent` vs `brandPink`).
- Shadow opacities/blur and corner radii (estimated from screenshots).
- Export a proper Figma **variables** set to replace these sampled values.

## Related

- [[flutter-architecture]] — where these tokens live (`core/theme/`)
- [[navigation]] — bottom bar + shared sheet/modal patterns
- [[screen-splash]] — brand-gradient theme
- [[screen-statistics]] — light-theme cards + circular progress
- [[README]]
