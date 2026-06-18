import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../core/network/dio_client.dart';
import '../core/network/token_store.dart';
import 'router.dart';
import '../features/auth/data/auth_api.dart';
import '../features/auth/data/auth_repository_impl.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/auth/presentation/cubit/login_cubit.dart';
import '../features/auth/presentation/cubit/register_cubit.dart';
import '../features/settings/data/settings_api.dart';
import '../features/splash/presentation/cubit/splash_cubit.dart';

/// Global service locator backed by get_it.
///
/// Call [configureDependencies] before `runApp()` (typically in `main()`).
/// Core registrations are lazy singletons; feature cubits are factories so each
/// screen gets a fresh instance.
final GetIt getIt = GetIt.instance;

void configureDependencies() {
  // --- Core: token persistence ---
  getIt.registerLazySingleton<TokenStore>(TokenStore.new);

  // --- Core: Dio client with interceptors ---
  getIt.registerLazySingleton<DioClient>(
    () => DioClient(
      tokenStore: getIt<TokenStore>(),
      onAuthExpired: _onAuthExpired,
    ),
  );

  // Expose the raw Dio instance for ad-hoc use or additional Retrofit clients.
  getIt.registerLazySingleton<Dio>(() => getIt<DioClient>().dio);

  // --- Feature: Auth ---
  getIt.registerLazySingleton<AuthApi>(() => AuthApi(getIt<Dio>()));
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      api: getIt<AuthApi>(),
      tokenStore: getIt<TokenStore>(),
    ),
  );
  getIt.registerFactory<LoginCubit>(
    () => LoginCubit(authRepository: getIt<AuthRepository>()),
  );
  getIt.registerFactory<RegisterCubit>(
    () => RegisterCubit(authRepository: getIt<AuthRepository>()),
  );
  getIt.registerFactory<SplashCubit>(
    () => SplashCubit(tokenStore: getIt<TokenStore>()),
  );

  // --- Feature: Settings API ---
  // GET /api/settings — no auth required.
  getIt.registerLazySingleton<SettingsApi>(() => SettingsApi(getIt<Dio>()));

  // TODO: register additional Retrofit APIs, repositories, and use-cases here
}

/// Called by [AuthInterceptor] when a token refresh fails: tokens have already
/// been cleared, so we route the app back to login. Uses the router's global
/// navigator key (no [BuildContext] available here). Idempotent: no-op if we are
/// already on `/login` (e.g. concurrent 401s).
void _onAuthExpired() {
  final context = appRouter.routerDelegate.navigatorKey.currentContext;
  if (context == null) return;
  final location = appRouter.routerDelegate.currentConfiguration.uri.path;
  if (location == '/login') return;
  appRouter.go('/login');
}
