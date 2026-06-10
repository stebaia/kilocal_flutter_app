import 'package:flutter/material.dart';
import 'package:kilocal_flutter_app/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';

class PathScreen extends StatelessWidget {
  const PathScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pathTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenGutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.spaceMd),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.pathOverallProgress, style: AppTypography.textTheme.labelMedium),
                  const SizedBox(height: AppSpacing.spaceXs),
                  LinearProgressIndicator(
                    value: 0.35,
                    backgroundColor: AppColors.accentSoft,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  const SizedBox(height: AppSpacing.spaceXs),
                  Text('23 / 132', style: AppTypography.numericAccent),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.spaceLg),
            _AreaTile(title: l10n.areaTraining, subtitle: '${l10n.month1} — ${l10n.pathCompletedPercent(80)}', icon: Icons.fitness_center),
            _AreaTile(title: l10n.areaNutrition, subtitle: '${l10n.month1} — ${l10n.pathCompletedPercent(60)}', icon: Icons.restaurant),
            _AreaTile(title: l10n.areaWellbeing, subtitle: '${l10n.month1} — ${l10n.pathCompletedPercent(45)}', icon: Icons.spa),
            _AreaTile(title: l10n.areaIntegration, subtitle: '${l10n.phase1} — ${l10n.pathCompletedPercent(30)}', icon: Icons.water_drop),
            const SizedBox(height: AppSpacing.spaceXl),
          ],
        ),
      ),
    );
  }
}

class _AreaTile extends StatelessWidget {
  const _AreaTile({required this.title, required this.subtitle, required this.icon});

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.spaceSm),
      child: AppCard(
        onTap: () {},
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.spaceSm),
              decoration: BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: AppColors.accent),
            ),
            const SizedBox(width: AppSpacing.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.textTheme.titleMedium),
                  Text(subtitle, style: AppTypography.textTheme.labelMedium),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}