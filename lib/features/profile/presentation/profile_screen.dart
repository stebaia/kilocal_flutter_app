import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kilocal_flutter_app/app/di.dart';
import 'package:kilocal_flutter_app/features/auth/domain/auth_repository.dart';
import 'package:kilocal_flutter_app/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import 'widgets/profile_header_card.dart';
import 'widgets/profile_tile.dart';

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

  void _showLogoutConfirmation(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.logoutConfirmationTitle),
        content: Text(l10n.logoutConfirmationMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.logoutCancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _performLogout(context);
            },
            child: Text(
              l10n.logoutConfirm,
              style: const TextStyle(color: AppColors.coral),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenGutter,
        ),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.spaceMd),
            const ProfileHeaderCard(
              name: 'Mario Rossi',
              email: 'mario@example.com',
            ),
            const SizedBox(height: AppSpacing.spaceLg),
            ProfileTile(
              icon: Icons.straighten,
              title: 'Silhouette',
              onTap: () {},
            ),
            ProfileTile(
              icon: Icons.info_outline,
              title: 'Tipo corporeo',
              onTap: () {},
            ),
            ProfileTile(
              icon: Icons.notifications_outlined,
              title: 'Notifiche',
              onTap: () {},
            ),
            ProfileTile(
              icon: Icons.settings_outlined,
              title: 'Impostazioni',
              onTap: () {},
            ),
            const SizedBox(height: AppSpacing.spaceLg),
            ProfileTile(
              icon: Icons.logout,
              title: l10n.profileLogout,
              onTap: () => _showLogoutConfirmation(context),
            ),
            const SizedBox(height: AppSpacing.spaceXl),
          ],
        ),
      ),
    );
  }
}
