import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';

/// Standard white card with rounded corners and soft shadow.
/// Use this across all light-theme screens.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    this.child,
    this.padding = const EdgeInsets.all(AppSpacing.spaceMd),
    this.onTap,
    this.color = AppColors.surface,
  });

  final Widget? child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  /// Background fill; defaults to the standard white surface. Override for
  /// cards that need a status-driven fill (e.g. the completed-material red
  /// card in the materials hub).
  final Color color;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        // The subtle grey outline only reads correctly against the default
        // white surface; a colored card (e.g. brand-red) supplies enough
        // contrast on its own and doesn't want it.
        border: color == AppColors.surface
            ? Border.all(color: AppColors.borderCard)
            : null,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}
