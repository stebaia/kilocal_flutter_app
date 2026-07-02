import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';

/// The four path-category shortcuts of the "percorsi" section on dashboard-type
/// (`private_sec_percorsi`, `layout: icons`). Tapping a category opens its path
/// area (`/path/:area`).
class ProfileTypePercorsiGrid extends StatelessWidget {
  const ProfileTypePercorsiGrid({super.key});

  static const _categories = <_PercorsoCategory>[
    _PercorsoCategory('allenamento', AppIcons.training),
    _PercorsoCategory('alimentazione', AppIcons.food),
    _PercorsoCategory('benessere', AppIcons.wellness),
    _PercorsoCategory('integrazione', AppIcons.flash),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        for (var i = 0; i < _categories.length; i++) ...[
          if (i != 0) const SizedBox(width: AppSpacing.spaceSm),
          Expanded(
            child: _CategoryTile(
              category: _categories[i],
              label: _labelFor(_categories[i].area, l10n),
              onTap: () => context.go('/path/${_categories[i].area}'),
            ),
          ),
        ],
      ],
    );
  }

  String _labelFor(String area, AppLocalizations l10n) {
    return switch (area) {
      'allenamento' => l10n.areaTraining,
      'alimentazione' => l10n.areaNutrition,
      'benessere' => l10n.areaWellbeing,
      'integrazione' => l10n.areaIntegration,
      _ => area,
    };
  }
}

class _PercorsoCategory {
  const _PercorsoCategory(this.area, this.iconName);

  final String area;
  final String iconName;
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.label,
    required this.onTap,
  });

  final _PercorsoCategory category;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: AppShadows.card,
            ),
            alignment: Alignment.center,
            child: AppIcon(
              category.iconName,
              size: 26,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: AppSpacing.spaceXs),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.textTheme.labelMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
