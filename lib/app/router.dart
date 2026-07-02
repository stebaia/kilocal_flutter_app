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
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/benefits/presentation/benefits_screen.dart';
import '../features/diary/presentation/diary_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/path/domain/entities/path_area_detail.dart';
import '../features/path/presentation/path_area_detail_screen.dart';
import '../features/path/presentation/path_material_detail_screen.dart';
import '../features/path/presentation/path_materials_screen.dart';
import '../features/path/presentation/path_screen.dart';
import '../features/path/presentation/path_step_screen.dart';
import '../features/path/presentation/path_timeframe_steps_screen.dart';
import '../features/profile/presentation/profile_form_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/profile/presentation/profile_type_screen.dart';
import '../features/profile/presentation/profile_type_percorsi_screen.dart';
import '../features/splash/presentation/splash_screen.dart';
import '../features/momenti/presentation/momenti_screen.dart';
import '../features/notifications/presentation/notifications_screen.dart';
import '../features/statistics/presentation/statistics_screen.dart';
import '../features/survey/presentation/survey_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
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
      path: '/statistics',
      builder: (context, state) => const StatisticsScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/survey',
      // `internalName` selects the CMS survey (type_survey, starter_kit,
      // qr_pharmacy_1/2, single_product_survey). Defaults to the initial survey.
      builder: (context, state) => SurveyScreen(
        internalName:
            state.uri.queryParameters['internalName'] ?? 'type_survey',
      ),
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
                  builder: (context, state) =>
                      PathAreaDetailScreen(area: state.pathParameters['area']!),
                  routes: [
                    GoRoute(
                      path: 'timeframe/:timeframeId',
                      builder: (context, state) => PathTimeframeStepsScreen(
                        area: state.pathParameters['area']!,
                        timeframeId: int.parse(
                          state.pathParameters['timeframeId']!,
                        ),
                        group: state.extra as PathTimeframeGroup?,
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
              path: '/benefits',
              builder: (context, state) => const BenefitsScreen(),
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
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _items = [
    AppIcons.home,
    AppIcons.path,
    AppIcons.diary,
    AppIcons.benefits,
    AppIcons.popsicle,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
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
                    navigationShell.goBranch(index);
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
