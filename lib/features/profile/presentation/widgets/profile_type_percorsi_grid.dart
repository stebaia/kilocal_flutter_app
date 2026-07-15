import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import 'profile_type_percorsi_sheet.dart';

/// The four path-category shortcuts of the "percorsi" section on dashboard-type
/// (`private_sec_percorsi`, `layout: icons`). Tapping a category opens a bottom
/// sheet describing how the path is personalised for the user's biotype.
///
/// Pill-shaped buttons (radius 40, 1px border) tinted with the biotype
/// [accentColor] (`main_color`), under a colored section label.
class ProfileTypePercorsiGrid extends StatelessWidget {
  const ProfileTypePercorsiGrid({
    super.key,
    required this.accentColor,
    this.areaTexts = const {},
  });

  /// Biotype `main_color`; tints the label, borders and icons.
  final Color accentColor;

  /// Per-area silhouette text keyed by area slug; shown in the sheet on tap.
  final Map<String, String> areaTexts;

  static const _categories = <_PercorsoCategory>[
    _PercorsoCategory('allenamento', AppIcons.training),
    _PercorsoCategory('alimentazione', AppIcons.food),
    _PercorsoCategory('benessere', AppIcons.wellness),
    // Integrazione is a phase-based area with its own screen: the tile jumps
    // straight to it instead of opening the biotype description sheet.
    _PercorsoCategory(
      'integrazione',
      AppIcons.supplement,
      route: '/path/integrazione',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 12,),
        Text(
          l10n.profileTypePathToFeelBest,
          style: AppTypography.textTheme.titleSmall?.copyWith(
            color: accentColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.spaceSm),
        Row(
          children: [
            for (var i = 0; i < _categories.length; i++) ...[
              if (i != 0) const SizedBox(width: AppSpacing.spaceSm),
              Expanded(
                child: _CategoryTile(
                  category: _categories[i],
                  accentColor: accentColor,
                  onTap: () {
                    final route = _categories[i].route;
                    if (route != null) {
                      context.push(route);
                      return;
                    }
                    showProfileTypePercorsiSheet(
                      context,
                      area: _categories[i].area,
                      title: _labelFor(_categories[i].area, l10n),
                      body: areaTexts[_categories[i].area],
                      accentColor: accentColor,
                    );
                  },
                ),
              ),
            ],
          ],
        ),
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
  const _PercorsoCategory(this.area, this.iconName, {this.route});

  final String area;
  final String iconName;

  /// When set, tapping the tile navigates to this route instead of opening the
  /// biotype description sheet.
  final String? route;
}

/// A pill-shaped, bordered category button with a centered biotype-colored icon.
class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.accentColor,
    required this.onTap,
  });

  final _PercorsoCategory category;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: accentColor, width: 1),
        ),
        alignment: Alignment.center,
        child: AppIcon(category.iconName, size: 26, color: accentColor),
      ),
    );
  }
}
