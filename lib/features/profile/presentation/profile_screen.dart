import 'package:flutter/material.dart';
import 'package:kilocal_flutter_app/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenGutter),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.spaceMd),
            AppCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.accentSoft,
                    child: const Icon(Icons.person, size: 32, color: AppColors.accent),
                  ),
                  const SizedBox(width: AppSpacing.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mario Rossi', style: AppTypography.textTheme.titleMedium),
                        Text('mario@example.com', style: AppTypography.textTheme.labelMedium),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.textSecondary),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.spaceLg),
            _ProfileTile(icon: Icons.straighten, title: 'Silhouette', onTap: () {}),
            _ProfileTile(icon: Icons.info_outline, title: 'Tipo corporeo', onTap: () {}),
            _ProfileTile(icon: Icons.notifications_outlined, title: 'Notifiche', onTap: () {}),
            _ProfileTile(icon: Icons.settings_outlined, title: 'Impostazioni', onTap: () {}),
            const SizedBox(height: AppSpacing.spaceXl),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({required this.icon, required this.title, required this.onTap});

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.spaceSm),
      child: AppCard(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: AppColors.accent),
            const SizedBox(width: AppSpacing.spaceMd),
            Expanded(child: Text(title, style: AppTypography.textTheme.bodyMedium)),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}