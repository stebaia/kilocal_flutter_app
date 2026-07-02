import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// A standalone white card row used in the "Informazioni sui prodotti" section:
/// a rounded-square icon badge, a title and a trailing chevron. The badge is
/// filled with [badgeColor] (the biotype `main_color`) or the brand gradient.
class ProfileProductTile extends StatelessWidget {
  const ProfileProductTile({
    super.key,
    required this.icon,
    required this.title,
    this.badgeColor,
    this.onTap,
  });

  final IconData icon;
  final String title;

  /// Background of the icon badge (`main_color`). Falls back to the brand
  /// gradient when null.
  final Color? badgeColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: badgeColor,
                gradient: badgeColor == null ? AppColors.brandGradient : null,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: AppColors.neutralWhite, size: 24),
            ),
            const SizedBox(width: AppSpacing.spaceMd),
            Expanded(
              child: Text(
                title,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textPrimary),
          ],
        ),
      ),
    );
  }
}
