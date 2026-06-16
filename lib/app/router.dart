import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../core/icons/app_icons.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_shadows.dart';
import '../core/theme/app_spacing.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/benefits/presentation/benefits_screen.dart';
import '../features/diary/presentation/diary_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/path/presentation/path_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
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
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
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
      builder: (context, state) => const SurveyScreen(),
    ),
    GoRoute(
      path: '/momenti/:id',
      builder: (context, state) => const MomentiScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => AppScaffold(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [GoRoute(path: '/home', builder: (context, state) => const HomeScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/path', builder: (context, state) => const PathScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/diary', builder: (context, state) => const DiaryScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/benefits', builder: (context, state) => const BenefitsScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen())],
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
                final color = isSelected ? AppColors.accent : AppColors.textSecondary;

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
                      child: AppIcon(
                        item,
                        size: 20,
                        color: color,
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