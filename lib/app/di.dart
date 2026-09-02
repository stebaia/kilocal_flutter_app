import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../core/config/env.dart';
import '../core/monitoring/analytics_events.dart';
import '../core/monitoring/analytics_service.dart';
import '../core/monitoring/firebase_analytics_service.dart';
import '../core/monitoring/firebase_monitoring_service.dart';
import '../core/monitoring/monitoring_service.dart';
import '../core/monitoring/performance_interceptor.dart';
import '../core/network/dio_client.dart';
import '../core/network/graphql_client.dart';
import '../core/network/token_store.dart';
import '../core/push/device_token_api.dart';
import '../core/push/device_token_registrar.dart';
import '../core/push/push_notification_service.dart';
import 'router.dart';
import '../features/auth/data/auth_api.dart';
import '../features/auth/data/auth_repository_impl.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/auth/presentation/cubit/forgot_password_cubit.dart';
import '../features/auth/presentation/cubit/login_cubit.dart';
import '../features/auth/presentation/cubit/register_cubit.dart';
import '../features/benefits/data/benefits_repository_impl.dart';
import '../features/benefits/domain/benefits_repository.dart';
import '../features/benefits/presentation/cubit/benefits_cubit.dart';
import '../features/diary/data/diary_repository_impl.dart';
import '../features/diary/domain/diary_repository.dart';
import '../features/diary/presentation/cubit/diary_goals_cubit.dart';
import '../features/diary/presentation/cubit/diary_history_cubit.dart';
import '../features/profile/data/biotype_texts_loader.dart';
import '../features/profile/data/profile_kit_repository_impl.dart';
import '../features/profile/data/profile_page_repository_impl.dart';
import '../features/profile/domain/profile_kit_repository.dart';
import '../features/profile/domain/profile_page_repository.dart';
import '../features/profile/presentation/cubit/avatar_upload_cubit.dart';
import '../features/profile/presentation/cubit/change_password_cubit.dart';
import '../features/profile/presentation/cubit/profile_kit_cubit.dart';
import '../features/profile/presentation/cubit/profile_page_cubit.dart';
import '../features/profile/presentation/cubit/profile_update_cubit.dart';
import '../features/home/data/home_repository_impl.dart';
import '../features/home/domain/home_repository.dart';
import '../features/home/presentation/cubit/home_cubit.dart';
import '../features/momenti/data/momenti_repository_impl.dart';
import '../features/momenti/domain/momenti_repository.dart';
import '../features/momenti/presentation/cubit/momenti_cubit.dart';
import '../features/notifications/data/notifications_repository_impl.dart';
import '../features/notifications/domain/notifications_repository.dart';
import '../features/notifications/presentation/cubit/notifications_cubit.dart';
import '../features/integrazione/data/integrazione_reminder_service.dart';
import '../features/integrazione/data/integrazione_repository_impl.dart';
import '../features/integrazione/domain/integrazione_repository.dart';
import '../features/integrazione/presentation/cubit/integrazione_cubit.dart';
import '../features/path/data/path_materials_repository_impl.dart';
import '../features/path/data/path_repository_impl.dart';
import '../features/path/data/program_unlock_repository_impl.dart';
import '../features/path/data/system_timer_service.dart';
import '../features/path/presentation/widgets/path_timer_pill.dart';
import '../features/path/data/vimeo_oembed_service.dart';
import '../features/path/domain/path_materials_repository.dart';
import '../features/path/domain/path_repository.dart';
import '../features/path/domain/program_unlock_repository.dart';
import '../features/path/presentation/cubit/path_cubit.dart';
import '../features/path/presentation/cubit/path_detail_cubit.dart';
import '../features/path/presentation/cubit/path_material_detail_cubit.dart';
import '../features/path/presentation/cubit/path_materials_cubit.dart';
import '../features/path/presentation/cubit/program_unlock_cubit.dart';
import '../features/settings/data/settings_api.dart';
import '../features/statistics/data/statistics_repository_impl.dart';
import '../features/statistics/domain/statistics_repository.dart';
import '../features/statistics/presentation/cubit/statistics_cubit.dart';
import '../features/survey/data/survey_repository_impl.dart';
import '../features/survey/domain/survey_repository.dart';
import '../features/survey/presentation/cubit/survey_cubit.dart';
import '../features/splash/presentation/cubit/splash_cubit.dart';
import '../features/strumenti/gallery/data/gallery_api.dart';
import '../features/strumenti/gallery/data/gallery_repository_impl.dart';
import '../features/strumenti/gallery/domain/gallery_repository.dart';
import '../features/strumenti/gallery/presentation/cubit/gallery_cubit.dart';
import '../features/strumenti/glossario/data/glossario_repository_impl.dart';
import '../features/strumenti/glossario/domain/glossario_repository.dart';
import '../features/strumenti/glossario/presentation/cubit/glossario_cubit.dart';
import '../features/strumenti/promemoria/data/promemoria_api.dart';
import '../features/strumenti/promemoria/data/promemoria_notification_service.dart';
import '../features/strumenti/promemoria/data/promemoria_repository_impl.dart';
import '../features/strumenti/promemoria/domain/promemoria_repository.dart';
import '../features/strumenti/promemoria/presentation/cubit/promemoria_cubit.dart';
import '../features/user/data/user_api.dart';
import '../features/user/data/user_repository_impl.dart';
import '../features/user/domain/user_repository.dart';
import '../features/user/presentation/cubit/user_cubit.dart';

/// Global service locator backed by get_it.
///
/// Call [configureDependencies] before `runApp()` (typically in `main()`).
/// Core registrations are lazy singletons; feature cubits are factories so each
/// screen gets a fresh instance.
final GetIt getIt = GetIt.instance;

void configureDependencies() {
  // --- Core: monitoring & analytics ---
  // Registered first so the Dio client can attach the performance interceptor
  // and other layers can report errors/events. Swap the Firebase impls for the
  // Noop variants in tests via a test-only DI setup.
  // The `staging` Android flavor has no app registered in the Firebase
  // project yet, so it falls back to Noop implementations instead of
  // touching the Firebase SDKs at all.
  if (Env.isFirebaseEnabled) {
    getIt.registerLazySingleton<MonitoringService>(
      () => FirebaseMonitoringService(),
    );
    getIt.registerLazySingleton<AnalyticsService>(
      () => FirebaseAnalyticsService(),
    );
    getIt.registerLazySingleton<PushNotificationService>(
      () => PushNotificationService(),
    );
    // Bridges the FCM token to `POST/DELETE /profile/device-tokens`. Resolved
    // lazily, so the Dio registration below is in place by the time it is used.
    getIt.registerLazySingleton<DeviceTokenApi>(
      () => DeviceTokenApi(getIt<Dio>()),
    );
    getIt.registerLazySingleton<DeviceTokenRegistrar>(
      () => DeviceTokenRegistrar(
        api: getIt<DeviceTokenApi>(),
        push: getIt<PushNotificationService>(),
      ),
    );
  } else {
    getIt.registerLazySingleton<MonitoringService>(NoopMonitoringService.new);
    getIt.registerLazySingleton<AnalyticsService>(
      () => const NoopAnalyticsService(),
    );
  }
  getIt.registerLazySingleton<AnalyticsEvents>(
    () => AnalyticsEvents(getIt<AnalyticsService>()),
  );

  // --- Core: token persistence ---
  getIt.registerLazySingleton<TokenStore>(TokenStore.new);

  // --- Core: Dio client with interceptors ---
  getIt.registerLazySingleton<DioClient>(
    () => DioClient(
      tokenStore: getIt<TokenStore>(),
      onAuthExpired: _onAuthExpired,
      // PerformanceInterceptor touches FirebasePerformance.instance, which
      // needs Firebase.initializeApp to have run — skip it entirely when
      // Firebase is disabled (staging flavor).
      extraInterceptors: Env.isFirebaseEnabled
          ? [PerformanceInterceptor()]
          : [],
    ),
  );

  // Expose the raw Dio instance for ad-hoc use or additional Retrofit clients.
  getIt.registerLazySingleton<Dio>(() => getIt<DioClient>().dio);

  // --- Core: GraphQL client ---
  getIt.registerLazySingleton<GraphqlClient>(
    () => GraphqlClient(dio: getIt<Dio>()),
  );

  // --- Feature: Auth ---
  getIt.registerLazySingleton<AuthApi>(() => AuthApi(getIt<Dio>()));
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      api: getIt<AuthApi>(),
      tokenStore: getIt<TokenStore>(),
      onLogout: getIt<UserCubit>().clear,
      // Revokes the FCM token while the session is still valid. Absent when
      // Firebase is disabled (staging flavor), in which case logout is unchanged.
      onBeforeLogout: _deviceTokenRegistrar?.unregisterCurrentToken,
    ),
  );

  // --- Feature: User session ---
  getIt.registerLazySingleton<UserApi>(() => UserApi(getIt<Dio>()));
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      userApi: getIt<UserApi>(),
      graphqlClient: getIt<GraphqlClient>(),
    ),
  );
  getIt.registerLazySingleton<UserCubit>(
    () => UserCubit(
      userRepository: getIt<UserRepository>(),
      monitoring: getIt<MonitoringService>(),
      analytics: getIt<AnalyticsService>(),
      deviceTokenRegistrar: _deviceTokenRegistrar,
    ),
  );

  getIt.registerFactory<LoginCubit>(
    () => LoginCubit(
      authRepository: getIt<AuthRepository>(),
      userCubit: getIt<UserCubit>(),
      analytics: getIt<AnalyticsEvents>(),
    ),
  );
  getIt.registerFactory<RegisterCubit>(
    () => RegisterCubit(
      authRepository: getIt<AuthRepository>(),
      userCubit: getIt<UserCubit>(),
      analytics: getIt<AnalyticsEvents>(),
    ),
  );
  getIt.registerFactory<ForgotPasswordCubit>(
    () => ForgotPasswordCubit(authRepository: getIt<AuthRepository>()),
  );

  // --- Feature: Home ---
  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(
      graphqlClient: getIt<GraphqlClient>(),
      dio: getIt<Dio>(),
      vimeoOembedService: getIt<VimeoOembedService>(),
    ),
  );
  getIt.registerFactory<HomeCubit>(
    () => HomeCubit(
      homeRepository: getIt<HomeRepository>(),
      userCubit: getIt<UserCubit>(),
    ),
  );

  // --- Feature: Path ---
  getIt.registerLazySingleton<PathRepository>(
    () => PathRepositoryImpl(
      dio: getIt<Dio>(),
      vimeoOembedService: getIt<VimeoOembedService>(),
    ),
  );
  getIt.registerFactory<PathCubit>(
    () => PathCubit(
      pathRepository: getIt<PathRepository>(),
      materialsRepository: getIt<PathMaterialsRepository>(),
      userCubit: getIt<UserCubit>(),
    ),
  );
  getIt.registerFactory<PathDetailCubit>(
    () => PathDetailCubit(
      pathRepository: getIt<PathRepository>(),
      materialsRepository: getIt<PathMaterialsRepository>(),
      analytics: getIt<AnalyticsEvents>(),
    ),
  );
  getIt.registerLazySingleton<StatisticsRepository>(
    () => StatisticsRepositoryImpl(dio: getIt<Dio>()),
  );
  getIt.registerFactory<StatisticsCubit>(
    () => StatisticsCubit(statisticsRepository: getIt<StatisticsRepository>()),
  );
  getIt.registerLazySingleton<PathMaterialsRepository>(
    () => PathMaterialsRepositoryImpl(
      graphqlClient: getIt<GraphqlClient>(),
      dio: getIt<Dio>(),
      vimeoOembedService: getIt<VimeoOembedService>(),
    ),
  );
  getIt.registerFactory<PathMaterialsCubit>(
    () => PathMaterialsCubit(
      materialsRepository: getIt<PathMaterialsRepository>(),
    ),
  );
  getIt.registerFactory<PathMaterialDetailCubit>(
    () => PathMaterialDetailCubit(
      materialsRepository: getIt<PathMaterialsRepository>(),
      userCubit: getIt<UserCubit>(),
    ),
  );
  getIt.registerLazySingleton<ProgramUnlockRepository>(
    () => ProgramUnlockRepositoryImpl(
      graphqlClient: getIt<GraphqlClient>(),
      userRepository: getIt<UserRepository>(),
    ),
  );
  getIt.registerFactory<ProgramUnlockCubit>(
    () => ProgramUnlockCubit(
      repository: getIt<ProgramUnlockRepository>(),
      userCubit: getIt<UserCubit>(),
    ),
  );
  getIt.registerLazySingleton<IntegrazioneRepository>(
    () => IntegrazioneRepositoryImpl(graphqlClient: getIt<GraphqlClient>()),
  );
  getIt.registerLazySingleton<IntegrazioneReminderService>(
    () => IntegrazioneReminderService(),
  );
  getIt.registerFactory<IntegrazioneCubit>(
    () => IntegrazioneCubit(
      repository: getIt<IntegrazioneRepository>(),
      userCubit: getIt<UserCubit>(),
      surveyRepository: getIt<SurveyRepository>(),
    ),
  );
  getIt.registerLazySingleton<VimeoOembedService>(() => VimeoOembedService());
  getIt.registerLazySingleton<SystemTimerService>(() => SystemTimerService());
  // Single shared instance so starting the timer from the path steps screen
  // or from strumenti drives the same countdown and the same overlay pill,
  // regardless of which screen started it or is currently visible.
  getIt.registerLazySingleton<PathTimerController>(
    () => PathTimerController(systemTimer: getIt<SystemTimerService>()),
  );

  // --- Feature: Benefits ---
  getIt.registerLazySingleton<BenefitsRepository>(
    () => BenefitsRepositoryImpl(graphqlClient: getIt<GraphqlClient>()),
  );
  getIt.registerFactory<BenefitsCubit>(
    () => BenefitsCubit(benefitsRepository: getIt<BenefitsRepository>()),
  );

  // --- Feature: Profile (CMS pages) ---
  getIt.registerLazySingleton<ProfilePageRepository>(
    () => ProfilePageRepositoryImpl(graphqlClient: getIt<GraphqlClient>()),
  );
  // Static silhouette texts (body-map points + path areas), bundled as an asset
  // until the backend exposes them.
  getIt.registerLazySingleton<BiotypeTextsLoader>(BiotypeTextsLoader.new);
  getIt.registerFactory<ProfilePageCubit>(
    () => ProfilePageCubit(repository: getIt<ProfilePageRepository>()),
  );
  getIt.registerFactory<ProfileUpdateCubit>(
    () => ProfileUpdateCubit(
      userRepository: getIt<UserRepository>(),
      userCubit: getIt<UserCubit>(),
    ),
  );
  getIt.registerFactory<AvatarUploadCubit>(
    () => AvatarUploadCubit(
      userRepository: getIt<UserRepository>(),
      userCubit: getIt<UserCubit>(),
    ),
  );
  getIt.registerFactory<ChangePasswordCubit>(
    () => ChangePasswordCubit(userRepository: getIt<UserRepository>()),
  );
  // Kit + supplement products ("Il mio Kit" / "Integrazione e prodotti").
  getIt.registerLazySingleton<ProfileKitRepository>(
    () => ProfileKitRepositoryImpl(graphqlClient: getIt<GraphqlClient>()),
  );
  getIt.registerFactory<ProfileKitCubit>(
    () => ProfileKitCubit(repository: getIt<ProfileKitRepository>()),
  );

  // --- Feature: Diary ---
  // Goals via REST (/journal/goals), history via GraphQL (user_activities).
  getIt.registerLazySingleton<DiaryRepository>(
    () => DiaryRepositoryImpl(
      dio: getIt<Dio>(),
      graphqlClient: getIt<GraphqlClient>(),
    ),
  );
  getIt.registerFactory<DiaryHistoryCubit>(
    () => DiaryHistoryCubit(repository: getIt<DiaryRepository>()),
  );
  getIt.registerFactory<DiaryGoalsCubit>(
    () => DiaryGoalsCubit(
      repository: getIt<DiaryRepository>(),
      surveyRepository: getIt<SurveyRepository>(),
    ),
  );

  // --- Feature: Momenti ---
  getIt.registerLazySingleton<MomentiRepository>(
    () => MomentiRepositoryImpl(graphqlClient: getIt<GraphqlClient>()),
  );
  getIt.registerFactory<MomentiCubit>(
    () => MomentiCubit(momentiRepository: getIt<MomentiRepository>()),
  );

  // --- Feature: Notifications ---
  getIt.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(graphqlClient: getIt<GraphqlClient>()),
  );
  getIt.registerFactory<NotificationsCubit>(
    () => NotificationsCubit(
      notificationsRepository: getIt<NotificationsRepository>(),
      userCubit: getIt<UserCubit>(),
    ),
  );

  getIt.registerFactory<SplashCubit>(
    () => SplashCubit(
      tokenStore: getIt<TokenStore>(),
      userCubit: getIt<UserCubit>(),
    ),
  );

  // --- Feature: Survey / onboarding ---
  getIt.registerLazySingleton<SurveyRepository>(
    () => SurveyRepositoryImpl(
      graphqlClient: getIt<GraphqlClient>(),
      dio: getIt<Dio>(),
    ),
  );
  getIt.registerFactory<SurveyCubit>(
    () => SurveyCubit(
      repository: getIt<SurveyRepository>(),
      analytics: getIt<AnalyticsEvents>(),
      // Shared with the unlock sheet so both accept the same barcodes.
      unlockRepository: getIt<ProgramUnlockRepository>(),
      userCubit: getIt<UserCubit>(),
    ),
  );

  // --- Feature: Strumenti / Promemoria ---
  // Backend-backed calendar reminders (GET/POST/DELETE /tools/reminders) with a
  // best-effort local notification scheduled per future reminder.
  getIt.registerLazySingleton<PromemoriaApi>(() => PromemoriaApi(getIt<Dio>()));
  getIt.registerLazySingleton<PromemoriaNotificationService>(
    () => PromemoriaNotificationService(),
  );
  getIt.registerLazySingleton<PromemoriaRepository>(
    () => PromemoriaRepositoryImpl(
      api: getIt<PromemoriaApi>(),
      notifications: getIt<PromemoriaNotificationService>(),
    ),
  );
  getIt.registerFactory<PromemoriaCubit>(
    () => PromemoriaCubit(repository: getIt<PromemoriaRepository>()),
  );

  // --- Feature: Strumenti / Foto Gallery ---
  // Writes are REST (POST/DELETE /tools/photo-gallery); the photo list and the
  // tool's copy are read over GraphQL. See [[photo-gallery-schema]].
  getIt.registerLazySingleton<GalleryApi>(() => GalleryApi(getIt<Dio>()));
  getIt.registerLazySingleton<GalleryRepository>(
    () => GalleryRepositoryImpl(
      api: getIt<GalleryApi>(),
      graphql: getIt<GraphqlClient>(),
    ),
  );
  getIt.registerFactory<GalleryCubit>(
    () => GalleryCubit(repository: getIt<GalleryRepository>()),
  );

  // --- Feature: Strumenti / Glossario ---
  // GraphQL-only: the glossary terms and the tool's copy. See
  // [[glossario-schema]].
  getIt.registerLazySingleton<GlossarioRepository>(
    () => GlossarioRepositoryImpl(graphql: getIt<GraphqlClient>()),
  );
  getIt.registerFactory<GlossarioCubit>(
    () => GlossarioCubit(repository: getIt<GlossarioRepository>()),
  );

  // --- Feature: Settings API ---
  // GET /api/settings — no auth required.
  getIt.registerLazySingleton<SettingsApi>(() => SettingsApi(getIt<Dio>()));

  // TODO: register additional Retrofit APIs, repositories, and use-cases here
}

/// The push-token registrar, or `null` when Firebase is disabled (the `staging`
/// Android flavor never registers it, so push wiring degrades to a no-op).
DeviceTokenRegistrar? get _deviceTokenRegistrar =>
    getIt.isRegistered<DeviceTokenRegistrar>()
    ? getIt<DeviceTokenRegistrar>()
    : null;

/// Called by [AuthInterceptor] when a 401 cannot be recovered by a token
/// refresh: the session is gone (expired, revoked, or the account was deleted
/// from the website), so we tear it down locally and route back to login.
///
/// [AuthInterceptor] only clears the tokens when the refresh call itself fails
/// with a [DioException] — when there is no refresh token at all it just gives
/// up — so we clear the store here too, and always clear [UserCubit] so no
/// profile data survives. Clearing the session also stops the router's
/// onboarding redirect from bouncing the user onto the pending survey.
///
/// Uses the router's global navigator key (no [BuildContext] available here).
/// Idempotent: no-op if we are already on `/login` (e.g. concurrent 401s).
Future<void> _onAuthExpired() async {
  final context = appRouter.routerDelegate.navigatorKey.currentContext;
  if (context == null) return;
  final location = appRouter.routerDelegate.currentConfiguration.uri.path;
  if (location == '/login') return;
  await getIt<TokenStore>().clear();
  getIt<UserCubit>().clear();
  appRouter.go('/login');
}
