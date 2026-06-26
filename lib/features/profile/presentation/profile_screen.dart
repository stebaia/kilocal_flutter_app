import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:kilocal_flutter_app/app/di.dart';
import 'package:kilocal_flutter_app/features/auth/domain/auth_repository.dart';
import 'package:kilocal_flutter_app/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import 'widgets/profile_group_card.dart';
import 'widgets/profile_list_tile.dart';
import 'widgets/profile_section_label.dart';
import 'widgets/profile_type_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _performLogout(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    try {
      await getIt<AuthRepository>().logout();
      if (context.mounted) {
        context.go('/login');
      }
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.errorGeneric)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final statusBarHeight = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.surface,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            // White filler behind the status bar.
            Container(color: AppColors.surface, height: statusBarHeight),
            // White header with title + avatar.
            Container(
              width: double.infinity,
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenGutter,
                AppSpacing.spaceXs,
                AppSpacing.screenGutter,
                AppSpacing.spaceLg,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.profileTitle,
                      style: AppTypography.textTheme.headlineLarge,
                    ),
                  ),
                  const _ProfileAvatar(),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenGutter,
                  AppSpacing.spaceLg,
                  AppSpacing.screenGutter,
                  AppSpacing.spaceXl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Il mio Tipo ---
                    ProfileSectionLabel(text: l10n.profileMyTypeSection),
                    const SizedBox(height: AppSpacing.spaceSm),
                    ProfileTypeCard(
                      label: l10n.profileMyTypeValue,
                      onTap: () {},
                    ),
                    const SizedBox(height: AppSpacing.spaceLg),

                    // --- Nome categoria sezioni ---
                    ProfileSectionLabel(text: l10n.profileCategorySection),
                    const SizedBox(height: AppSpacing.spaceSm),
                    ProfileGroupCard(
                      tiles: [
                        ProfileListTile(
                          icon: Icons.description_outlined,
                          title: l10n.profilePersonalData,
                          onTap: () {},
                        ),
                        ProfileListTile(
                          icon: Icons.description_outlined,
                          title: l10n.profileMyAccount,
                          onTap: () {},
                        ),
                        ProfileListTile(
                          icon: Icons.description_outlined,
                          title: l10n.profileFoodPreferences,
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.spaceLg),

                    // --- Notifiche ---
                    ProfileSectionLabel(text: l10n.profileNotificationsSection),
                    const SizedBox(height: AppSpacing.spaceSm),
                    ProfileGroupCard(
                      tiles: [
                        ProfileListTile(
                          icon: Icons.description_outlined,
                          title: l10n.profilePushNotifications,
                          subtitle: l10n.profilePushNotificationsStatus,
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.spaceLg),

                    // --- Assistenza ---
                    ProfileSectionLabel(text: l10n.profileSupportSection),
                    const SizedBox(height: AppSpacing.spaceSm),
                    ProfileGroupCard(
                      tiles: [
                        ProfileListTile(
                          icon: Icons.description_outlined,
                          title: l10n.profileTutorial,
                          onTap: () {},
                        ),
                        ProfileListTile(
                          icon: Icons.description_outlined,
                          title: l10n.profileContactSupport,
                          onTap: () {},
                        ),
                        ProfileListTile(
                          icon: Icons.logout,
                          title: l10n.profileLogout,
                          onTap: () => _performLogout(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Circular avatar shown in the profile header (top-right).
class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.accentSoft,
      ),
      clipBehavior: Clip.antiAlias,
      child: const Icon(
        Icons.person,
        color: AppColors.accent,
        size: 28,
      ),
    );
  }
}
