# Auth implementation plan — Login & Registration

Implementation plan for login + registration in the **mobile app** (Directus + Bearer JWT).
API contract: [[authentication]] + [[registration]]. Screen: [[screen-login]].
Status: **implemented**. Created 2026-06-18.

## Context / constraints

- Deps already present (no new ones): `dio`, `retrofit` + `retrofit_generator`,
  `json_serializable` + `json_annotation`, `get_it`, `go_router`, `flutter_secure_storage`,
  `flutter_bloc`.
- DI: `lib/app/di.dart` (get_it, lazy singletons). Router: `lib/app/router.dart`. Retrofit
  pattern already used in `features/settings/data/settings_api.dart`.
- Current scaffolding is wired to the **legacy shop** (cookies, `{SHOP_URL}/cms/auth/*`) and
  `login_cubit.dart` is a **mock** (1s delay). Must be rewired to Directus.

### Decisions

- Post-login routing → **explicit TODO** (login → `/home` for now; branch by `profile_status`
  to be confirmed with the team — see [[missing-apis]]).
- Presentation: **Cubit** (consistent with existing `onboarding_cubit`); switch to `AuthBloc`
  only if desired.
- `CookieStore` → rename to `TokenStore` (it stores tokens, not cookies). Alternative: keep the
  name, just clean the `klkl-*` keys.

## Phase 0 — Config & networking (base, do first)

1. **`core/config/env.dart`** — replace `shopUrl`/`cmsUrl` with a single `baseUrl` →
   `https://cms-stg.kilocal.thefullproject.it` (staging), override via
   `--dart-define=API_BASE_URL=…` for prod (`https://cms.kilocalprogram.it`).
2. **`core/network/dio_client.dart`** — `baseUrl: Env.baseUrl`; remove
   `extra['withCredentials'] = true` (native app, no cookies).
3. **`core/network/auth_interceptor.dart`** — `_tryRefresh()` → `POST /auth/refresh` (relative)
   with body `{ refresh_token, mode: 'json' }`. Response parsing (`data.access_token` /
   `data.refresh_token`) already matches `AuthTokens`. Keep single-shot retry + `onAuthExpired`.
4. **`core/network/cookie_store.dart` → `token_store.dart`** — rename `CookieStore` →
   `TokenStore`; drop `klkl-data` / `sessionData` (shop residue); keep `access_token` +
   `refresh_token` on `flutter_secure_storage`. Update references in `di.dart`, `dio_client`,
   `auth_interceptor`.

## Phase 1 — `features/auth/data`

5. **`data/dto/auth_tokens_dto.dart`** — `{ data: { access_token, refresh_token, expires } }`.
6. **`data/dto/register_response_dto.dart`** — `{ id, email, first_name, last_name }`.
7. **`data/auth_api.dart`** (Retrofit `@RestApi`):
   - `POST /auth/login` → body `{ email, password, mode:'json' }` → `AuthTokensDto`
   - `POST /auth/logout` → `{ refresh_token, mode:'json' }` → void (204)
   - `POST /api/auth/register` → full body (`origin:'app'`) → `RegisterResponseDto`
   - `POST /api/auth/password-forgotten` → `{ email, origin:'app' }`
   - (refresh stays in the interceptor with a bare Dio — not here — to avoid recursive 401)
   - Run `dart run build_runner build`.
8. **`data/auth_repository_impl.dart`** — calls `AuthApi`; on login/refresh saves tokens to
   `TokenStore`, on logout clears them. Maps Dio errors via `core/network/api_exception.dart`
   (`401`→credentials, `409`→email exists, `400`→payload). See [[errors]].

## Phase 2 — `features/auth/domain`

9. **`domain/auth_repository.dart`** (abstract): `login`, `register`, `logout`,
   `requestPasswordReset`, `isAuthenticated`.
10. **`domain/entities/`** — optional; DTOs likely suffice for auth.

## Phase 3 — `features/auth/presentation`

11. Replace mock **`login_cubit.dart`**: inject `AuthRepository`; `login()` calls the repo;
    emit `failure` with mapped error. Add client-side validation (email format, non-empty
    password).
12. **`register_screen.dart`** + `register_cubit.dart` / `register_state.dart` — Figma fields
    (first/last name, email, password, confirm, privacy/newsletter). Reuse `login_form_card`,
    `login_submit_button`. Validate `password == password_confirm`.
13. **`login_screen.dart`** — inject cubit from get_it; surface `failure` (SnackBar/inline).

## Phase 4 — DI & routing

14. **`app/di.dart`** — register `AuthApi`, `AuthRepository → AuthRepositoryImpl`,
    `LoginCubit` / `RegisterCubit` (factory); rename `CookieStore` → `TokenStore`.
15. **`app/router.dart`** — add `GoRoute('/signup')` → `RegisterScreen`. On login success →
    `context.go('/home')` **+ TODO**: `// TODO(team): branch by profile_status —
    GET /survey/me/status decides home vs /survey. See wiki/missing-apis.md`. (Optional later:
    GoRouter global redirect on `TokenStore.hasSession` to guard routes.)

## Phase 5 — Verify

16. `dart run build_runner build --delete-conflicting-outputs`.
17. `dart analyze` + `dart format`.
18. Manual smoke: login (staging creds) → tokens saved → `/home`; register → `200`/`409`;
    forgotten password → `200`.
19. Unit tests: `AuthRepositoryImpl` (error mapping) + cubit (success/failure).

## Files touched / created

| Action | Files |
|--------|-------|
| Modify | `core/config/env.dart`, `core/network/dio_client.dart`, `core/network/auth_interceptor.dart`, `app/di.dart`, `app/router.dart`, `features/auth/presentation/login_screen.dart` + `cubit/login_cubit.dart` + `login_state.dart` |
| Rename | `core/network/cookie_store.dart` → `token_store.dart` |
| New | `features/auth/data/auth_api.dart`, `.../dto/auth_tokens_dto.dart`, `.../dto/register_response_dto.dart`, `.../auth_repository_impl.dart`, `features/auth/domain/auth_repository.dart`, `.../presentation/register_screen.dart` + cubit/state |

## Open questions (non-blocking)

1. Post-login routing (`profile_status` → home/survey) — TODO, confirm with team.
2. Bloc vs Cubit — plan uses Cubit; switch if desired.
3. Rename `CookieStore` → `TokenStore` (default) vs keep name + clean keys.

## Related

- [[authentication]]
- [[registration]]
- [[screen-login]]
- [[survey]]
- [[errors]]
- [[missing-apis]]
- [[flutter-architecture]]
