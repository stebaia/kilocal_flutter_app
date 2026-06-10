# Screen — Login / Sign up

Authentication entry point. Source: Figma flow `wiki/flow-screen/login.png`
(frame "Log in / sign up"). Backed by the [[authentication]] and [[users]] APIs.

## Purpose

Let the user **log in** (Accedi) or **register** (Registrati). Reached from
[[screen-onboarding]]; on success routes into the app shell ([[navigation]] → [[screen-home]])
or the [[screen-survey]] flow for first-time users.

## Screens

| Screen | Fields | Primary action |
|--------|--------|----------------|
| **Log in** (Accedi) | email, password | "Accedi" → [[authentication]] login |
| **Sign up** (Registrati) | first name, last name, email, password, password confirm, privacy/newsletter flags | "Registrati" → [[users]] registration |

- A "Password dimenticata?" link starts the forgotten-password flow ([[users]] →
  `POST /api/auth/password-forgotten`).
- Two visual variants exist in the design (light form and brand-colored form); same fields.

## Data / API

- Login: `POST /cms/auth/login` via [[authentication]] (Directus session cookies
  `klkl-data`, `klkl_refresh_token`).
- Registration: `POST /api/users` ([[users]]).
- Forgotten password: `POST /api/auth/password-forgotten` ([[users]]).

## Implementation notes

- Driven by `AuthBloc` (states: unauthenticated / authenticating / authenticated / expired) —
  see [[flutter-architecture]].
- Validate password confirmation client-side; server also returns `Passwords do not match`
  ([[users]]).
- Feature placement: `features/auth/presentation/`.

## Routing

`/login` (and `/signup`). On success → app shell ([[navigation]]); first login may redirect to
[[screen-survey]].

## Related

- [[authentication]]
- [[users]]
- [[screen-onboarding]]
- [[screen-survey]]
- [[navigation]]
- [[flutter-architecture]]
- [[README]]
