# Screen — Notifications

Notification center. Source: `wiki/flow-screen/notifiche.png` (frame "Notifiche"). Pushed on
top of the shell — see [[navigation]].

## Purpose

List notifications with filters, multiple notification types, and **swipe-to-archive**.

## Screens & elements

| Element | Description |
|---------|-------------|
| **List** (Notifiche) | Scrollable list: avatar/icon, Title, Content, timestamp, "…" menu |
| **Filters modal** (Modale filtri) | Tutte / Categoria / Archiviate |
| **Swipe action** | "Archivia notifica" on swipe |
| **Notification types** (Tipologie) | Plain text, with image, with one or two CTA buttons |

## Data / API

- Notification list, filters, and archive action are **not documented** — see [[missing-apis]]
  (§8). Should also provide an unread count for a bottom-bar badge.

## Implementation notes

- Feature placement: `features/notifications/presentation/`.
- Swipe-to-archive via `Dismissible`.

## Routing

`/notifications`.

## Related

- [[navigation]]
- [[missing-apis]]
- [[README]]
