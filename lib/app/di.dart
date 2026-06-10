import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../core/network/cookie_store.dart';
import '../core/network/dio_client.dart';
import '../features/settings/data/settings_api.dart';

/// Global service locator backed by get_it.
///
/// Call [configureDependencies] before `runApp()` (typically in `main()`).
/// All registrations are lazy singletons so they are instantiated on first use.
final GetIt getIt = GetIt.instance;

void configureDependencies() {
  // --- Core: cookie / token persistence ---
  getIt.registerLazySingleton<CookieStore>(CookieStore.new);

  // --- Core: Dio client with interceptors ---
  getIt.registerLazySingleton<DioClient>(
    () => DioClient(
      cookieStore: getIt<CookieStore>(),
      onAuthExpired: () {
        // TODO: emit an auth-expired event or route to login via a global listener
      },
    ),
  );

  // Expose the raw Dio instance for ad-hoc use or additional Retrofit clients.
  getIt.registerLazySingleton<Dio>(() => getIt<DioClient>().dio);

  // --- Feature: Settings API ---
  // GET /api/settings — no auth required.
  getIt.registerLazySingleton<SettingsApi>(
    () => SettingsApi(getIt<Dio>()),
  );

  // TODO: register additional Retrofit APIs, repositories, and use-cases here
}