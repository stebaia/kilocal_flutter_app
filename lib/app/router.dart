import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'di.dart';
import '../core/icons/app_icons.dart';
import '../core/utils/hex_color.dart';
import '../core/widgets/cms_svg_icon.dart';
import '../l10n/app_localizations.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_shadows.dart';
import '../core/theme/app_spacing.dart';
import '../features/user/presentation/cubit/user_cubit.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/benefits/presentation/benefits_screen.dart';
import '../features/diary/presentation/diary_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/integrazione/presentation/integrazione_phase_screen.dart';
import '../features/integrazione/presentation/integrazione_screen.dart';
import '../features/path/domain/entities/path_area_detail.dart';
import '../features/path/presentation/path_area_detail_screen.dart';
import '../features/path/presentation/path_area_group_detail_screen.dart';
import '../features/path/presentation/path_material_detail_screen.dart';
import '../features/path/presentation/path_materials_screen.dart';
import '../features/path/presentation/path_screen.dart';
import '../features/path/presentation/path_step_screen.dart';
import '../features/profile/presentation/change_password_screen.dart';
import '../features/profile/presentation/profile_form_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/profile/presentation/profile_kit_screen.dart';
import '../features/profile/presentation/profile_kit_products_screen.dart';
import '../features/profile/presentation/profile_type_screen.dart';
import '../features/profile/presentation/profile_type_percorsi_screen.dart';
import '../features/splash/presentation/splash_screen.dart';
import '../features/strumenti/domain/entities/strumento.dart';
import '../features/strumenti/presentation/strumenti_screen.dart';
import '../features/strumenti/presentation/strumento_detail_screen.dart';
import '../features/strumenti/gallery/presentation/gallery_screen.dart';
import '../features/strumenti/glossario/presentation/glossario_screen.dart';
import '../features/strumenti/promemoria/presentation/promemoria_screen.dart';
import '../features/strumenti/timer/presentation/timer_screen.dart';
import '../features/momenti/presentation/momenti_screen.dart';
import '../features/notifications/presentation/notifications_screen.dart';
import '../features/statistics/presentation/statistics_screen.dart';
import '../features/survey/presentation/survey_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Routes that must stay reachable while onboarding is pending: the auth flow
/// (there is no session to gate yet) and the survey itself (the destination).
const _onboardingExemptRoutes = {
  '/splash',
  '/onboarding',
  '/login',
  '/signup',
  '/forgot-password',
  '/survey',
};

/// The route a user must be forced onto for [pendingSurvey], or `null` to let
/// navigation to [path] proceed.
///
/// `user_details.profile_status` is the backend's content gate: while it names
/// a survey (e.g. `starter_kit` → the post-purchase barcode survey), the user
/// must complete that survey before reaching the rest of the app. Without this
/// a user could leave the survey — via back, a deep link or an in-app `go` —
/// and browse without having entered a proof of purchase.
///
/// [sessionLoaded] gates the whole rule: with no session there is nothing to
/// gate. The auth routes and the survey itself are exempt, otherwise login
/// would redirect onto itself.
@visibleForTesting
String? onboardingRedirectFor({
  required bool sessionLoaded,
  required String? pendingSurvey,
  required String path,
}) {
  if (!sessionLoaded) return null;
  if (pendingSurvey == null) return null;
  if (_onboardingExemptRoutes.contains(path)) return null;
  return '/survey?internalName=$pendingSurvey';
}

String? _onboardingRedirect(BuildContext context, GoRouterState state) {
  final userState = getIt<UserCubit>().state;
  return onboardingRedirectFor(
    sessionLoaded: userState.status == UserStatus.loaded,
    pendingSurvey: userState.profileStatus.surveyInternalName,
    path: state.uri.path,
  );
}

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  redirect: _onboardingRedirect,
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/statistics',
      builder: (context, state) => const StatisticsScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    // Benefits is a secondary page reached from the home action card
    // (not a bottom-nav tab), so it lives outside the shell.
    GoRoute(
      path: '/benefits',
      builder: (context, state) => const BenefitsScreen(),
    ),
    GoRoute(
      path: '/survey',
      // `internalName` selects the CMS survey (type_survey, starter_kit,
      // qr_pharmacy_1/2, single_product_survey). Defaults to the initial survey.
      builder: (context, state) {
        final internalName =
            state.uri.queryParameters['internalName'] ?? 'type_survey';
        return SurveyScreen(
          // Keyed by survey: chaining one onto another (type_survey →
          // starter_kit) keeps the same path, so without this the Element is
          // reused and the finished survey stays on screen.
          key: ValueKey('survey-$internalName'),
          internalName: internalName,
        );
      },
    ),
    GoRoute(
      path: '/momenti/:id',
      builder: (context, state) =>
          MomentiScreen(momentId: state.pathParameters['id']),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppScaffold(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/path',
              builder: (context, state) => const PathScreen(),
              routes: [
                GoRoute(
                  path: ':area',
                  builder: (context, state) {
                    final area = state.pathParameters['area']!;
                    // Integrazione is a phase-based GraphQL area, not a steps
                    // area — it has its own screen and does not hit /path/*/steps.
                    if (area == 'integrazione') {
                      return const IntegrazioneScreen();
                    }
                    return PathAreaDetailScreen(area: area);
                  },
                  routes: [
                    // Integrazione phase detail (phase-based, GraphQL). Only
                    // reachable for the `integrazione` area.
                    GoRoute(
                      path: 'phase/:phaseId',
                      builder: (context, state) => IntegrazionePhaseScreen(
                        phaseId: state.pathParameters['phaseId']!,
                      ),
                    ),
                    // Benessere sub-section detail (Mindfulness / Self care /
                    // Stili di vita). Only reachable for the `benessere` area.
                    GoRoute(
                      path: 'group/:groupId',
                      builder: (context, state) => PathAreaGroupDetailScreen(
                        groupId: state.pathParameters['groupId']!,
                        group: state.extra as PathAreaGroup?,
                      ),
                    ),
                    GoRoute(
                      path: 'step/:stepId',
                      builder: (context, state) => PathStepScreen(
                        area: state.pathParameters['area']!,
                        stepId: state.pathParameters['stepId']!,
                        step: state.extra as PathStepItem?,
                      ),
                    ),
                    GoRoute(
                      path: 'materials/:groupId',
                      builder: (context, state) => PathMaterialsScreen(
                        groupId: state.pathParameters['groupId']!,
                        title: state.extra as String?,
                      ),
                      routes: [
                        GoRoute(
                          path: 'detail/:materialId',
                          builder: (context, state) => PathMaterialDetailScreen(
                            materialId: state.pathParameters['materialId']!,
                            categoryTitle: state.extra as String?,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/diary',
              builder: (context, state) => const DiaryScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/strumenti',
              builder: (context, state) => const StrumentiScreen(),
              routes: [
                // Every tool now has its own screen; the `:id` placeholder
                // below only catches ids these routes don't cover.
                GoRoute(
                  path: 'promemoria',
                  builder: (context, state) => const PromemoriaScreen(),
                ),
                GoRoute(
                  path: 'timer',
                  builder: (context, state) => const TimerScreen(),
                ),
                GoRoute(
                  path: 'gallery',
                  builder: (context, state) => const GalleryScreen(),
                ),
                GoRoute(
                  path: 'glossario',
                  builder: (context, state) => const GlossarioScreen(),
                ),
                // Launched-tool destination. `:id` is a StrumentoId name;
                // unknown values fall back to the first tool.
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final id = StrumentoId.values.firstWhere(
                      (e) => e.name == state.pathParameters['id'],
                      orElse: () => StrumentoId.promemoria,
                    );
                    return StrumentoDetailScreen(id: id);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
              routes: [
                GoRoute(
                  path: 'type',
                  builder: (context, state) => const ProfileTypeScreen(),
                  routes: [
                    GoRoute(
                      path: 'percorsi',
                      builder: (context, state) =>
                          const ProfileTypePercorsiScreen(),
                    ),
                    // "Il mio Kit" plan card; kit id passed via extra (it comes
                    // from the session biotype, no need to re-resolve it).
                    GoRoute(
                      path: 'kit/:kitId',
                      builder: (context, state) => ProfileKitScreen(
                        kitId: state.pathParameters['kitId']!,
                      ),
                    ),
                    // "Integrazione e prodotti": the kit's supplement products.
                    GoRoute(
                      path: 'products/:kitId',
                      builder: (context, state) => ProfileKitProductsScreen(
                        kitId: state.pathParameters['kitId']!,
                      ),
                    ),
                  ],
                ),
                // Account forms — one screen per CMS `private_sec_profile` tab
                // (dashboard-profile). Tab ids: 1 personal data, 4 account
                // settings, 3 food preferences.
                GoRoute(
                  path: 'personal-data',
                  builder: (context, state) => ProfileFormScreen(
                    tabId: '1',
                    fallbackTitle: AppLocalizations.of(
                      context,
                    )!.profilePersonalData,
                  ),
                ),
                GoRoute(
                  path: 'account',
                  builder: (context, state) => ProfileFormScreen(
                    tabId: '4',
                    fallbackTitle: AppLocalizations.of(
                      context,
                    )!.profileMyAccount,
                  ),
                ),
                GoRoute(
                  path: 'food-preferences',
                  builder: (context, state) => ProfileFormScreen(
                    tabId: '3',
                    fallbackTitle: AppLocalizations.of(
                      context,
                    )!.profileFoodPreferences,
                  ),
                ),
                GoRoute(
                  path: 'change-password',
                  builder: (context, state) => const ChangePasswordScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

/// Notifies descendants (namely [HomeScreen]) that the Home tab was just
/// re-selected from a different tab, so they can reload their data.
class HomeReloadSignal extends InheritedNotifier<ValueNotifier<int>> {
  const HomeReloadSignal({
    super.key,
    required super.notifier,
    required super.child,
  });

  static ValueNotifier<int>? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<HomeReloadSignal>()
        ?.notifier;
  }
}

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  static const _items = [
    AppIcons.home,
    AppIcons.path,
    AppIcons.diary,
    AppIcons.strumenti,
    AppIcons.popsicle,
  ];

  // Bumped whenever the Home tab is (re)selected from a different tab, so
  // HomeScreen can reload — its BlocProvider otherwise only runs once, since
  // the shell's IndexedStack keeps its State alive across tab switches.
  final _homeReloadSignal = ValueNotifier<int>(0);

  @override
  void dispose() {
    _homeReloadSignal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navigationShell = widget.navigationShell;

    return Scaffold(
      body: HomeReloadSignal(
        notifier: _homeReloadSignal,
        child: navigationShell,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppRadius.lg),
            topRight: Radius.circular(AppRadius.lg),
          ),
          boxShadow: AppShadows.bar,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.spaceSm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_items.length, (index) {
                final isSelected = navigationShell.currentIndex == index;
                final item = _items[index];
                final color = isSelected
                    ? AppColors.accent
                    : AppColors.textSecondary;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    // Home's IndexedStack branch keeps HomeScreen's State (and
                    // its HomeCubit) alive across tab switches, so returning
                    // to it after e.g. completing a step elsewhere would show
                    // stale data. Bump its key to force a remount — and thus
                    // a fresh HomeCubit.load() — whenever we land on Home
                    // from a different tab.
                    if (index == 0 && navigationShell.currentIndex != 0) {
                      _homeReloadSignal.value++;
                    }
                    // Always land on the branch's root screen, never wherever
                    // it was last left — `goBranch` otherwise restores that
                    // branch's own navigation stack (GoRouter's default), so a
                    // "consiglio utile" opened inside /path would still be
                    // showing after leaving to /strumenti and coming back.
                    navigationShell.goBranch(index, initialLocation: true);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: isSelected
                        ? BoxDecoration(
                            color: AppColors.accentSoft,
                            shape: BoxShape.circle,
                          )
                        : null,
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: _NavIcon(
                        item: item,
                        color: color,
                        isSelected: isSelected,
                        // The profile tab (last) shows the user's biotype icon
                        // from the CMS when available.
                        useBiotypeIcon: index == _items.length - 1,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

/// A bottom-bar icon. For the profile tab ([useBiotypeIcon]) it shows the user's
/// biotype icon from the CMS (tinted with the current [color]), falling back to
/// the static [item] SVG when the biotype or its icon is unavailable.
class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.item,
    required this.color,
    required this.isSelected,
    required this.useBiotypeIcon,
  });

  final String item;
  final Color color;
  final bool isSelected;
  final bool useBiotypeIcon;

  @override
  Widget build(BuildContext context) {
    if (!useBiotypeIcon) {
      return AppIcon(item, size: 20, color: color);
    }

    return BlocBuilder<UserCubit, UserState>(
      bloc: getIt<UserCubit>(),
      builder: (context, state) {
        final biotype = state.details?.biotype;
        // Selected: tint with the biotype colour (main_color), falling back to
        // the accent. Unselected: keep the muted grey for a clear active state.
        final iconColor = isSelected
            ? (colorFromHex(biotype?.mainColor) ?? AppColors.accent)
            : color;
        final fallback = AppIcon(item, size: 20, color: iconColor);

        final iconUrl = biotype?.iconUrl;
        if (iconUrl == null) return fallback;
        return CmsSvgIcon(
          url: iconUrl,
          size: 20,
          color: iconColor,
          fallback: fallback,
        );
      },
    );
  }
}
