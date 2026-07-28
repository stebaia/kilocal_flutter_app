import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/icons/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_header.dart';
import '../../../l10n/app_localizations.dart';
import '../../statistics/presentation/statistics_screen.dart';
import '../domain/entities/path_area_detail.dart';
import 'widgets/path_area_hero_card.dart';
import 'widgets/path_locked_sheets.dart';
import 'widgets/path_materials_row.dart';
import 'widgets/path_section_header.dart';
import 'widgets/path_timeframe_row.dart';
import 'widgets/wellbeing_group_style.dart';

/// Detail of a single Benessere sub-section (Mindfulness / Self care / Stili di
/// vita). Mirrors the area detail layout — hero card, progress section and the
/// "Materiali extra" row — but scoped to the tapped group.
class PathAreaGroupDetailScreen extends StatefulWidget {
  const PathAreaGroupDetailScreen({
    super.key,
    required this.groupId,
    required this.group,
  });

  final String groupId;

  /// Group passed from the wellbeing list. Nullable on a cold deep-link, in
  /// which case only the id is known and the header falls back to a generic
  /// title.
  final PathAreaGroup? group;

  @override
  State<PathAreaGroupDetailScreen> createState() =>
      _PathAreaGroupDetailScreenState();
}

class _PathAreaGroupDetailScreenState extends State<PathAreaGroupDetailScreen> {
  // Set once a step is completed while this screen is open, so backing out
  // (through the area detail screen) eventually tells PathScreen to refresh
  // its overall progress card. See [[statistics-feature-status]].
  bool _hasProgressed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final group = widget.group;
    final title = group?.title ?? l10n.areaWellbeing;
    // The known wellbeing titles are matched by keyword inside
    // [WellbeingGroupStyle.of], so the index fallback only matters for an
    // unrecognized title — 0 is a safe default here.
    final style = WellbeingGroupStyle.of(title, 0);
    final completed = group?.completed ?? 0;
    final total = group?.total ?? 0;
    final percent = total == 0 ? 0 : ((completed / total) * 100).round();
    final months = group?.months ?? const <PathTimeframeGroup>[];

    return Scaffold(
      backgroundColor: AppColors.surface,
      // top: false — AppHeader insets the status bar; SafeArea guards only the
      // bottom against the Android system navigation bar.
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppHeader(
              title: title,
              showBack: true,
              onBack: () => Navigator.of(context).pop(_hasProgressed),
              trailing: GestureDetector(
                onTap: () => context.push(StatisticsScreen.route),
                child: const AppIcon(
                  AppIcons.chart,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenGutter,
                  vertical: AppSpacing.spaceMd,
                ),
                children: [
                  PathAreaHeroCard(
                    title: title,
                    assetName: style.assetName,
                    iconName: style.iconName,
                    completed: completed,
                    total: total,
                  ),
                  const SizedBox(height: AppSpacing.spaceLg),
                  PathSectionHeader(
                    title: l10n.pathAreaProgressLabel,
                    trailing: l10n.pathCompletedPercent(percent),
                  ),
                  const SizedBox(height: AppSpacing.spaceSm),
                  // Always show every month; a month with no steps in this group
                  // renders locked with a 0/0 count.
                  for (var i = 0; i < months.length; i++)
                    PathTimeframeRow(
                      group: months[i],
                      subtitle: _monthSubtitle(l10n, months[i]),
                      showConnectorTop: i > 0,
                      showConnectorBottom: i < months.length - 1,
                      onTap: months[i].isLocked
                          ? () => showTimeframeLockedSheet(
                              context,
                              currentMonth: _referenceMonthFor(months),
                            )
                          : () => _openTimeframe(context, months[i]),
                    ),
                  const SizedBox(height: AppSpacing.spaceSm),
                  const Divider(height: 1, color: AppColors.dividerStrong),
                  const SizedBox(height: AppSpacing.spaceSm),
                  PathMaterialsRow(
                    title: l10n.pathMaterialsTitle,
                    subtitle: l10n.pathMaterialsSubtitle,
                    onTap: () => context.push(
                      '/path/benessere/materials/${widget.groupId}',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spaceXl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _monthSubtitle(AppLocalizations l10n, PathTimeframeGroup month) {
    if (month.isLocked) return l10n.pathTimeframeLocked;
    if (month.isCurrent) return l10n.pathTimeframeCurrent;
    return l10n.pathTimeframeStepsCount(month.total);
  }

  /// The month the "mese bloccato" sheet should name as "still to finish" —
  /// the active month (`isCurrent`), or as a fallback the last unlocked,
  /// not-yet-completed month, since a locked future month is always blocked
  /// on finishing whichever month is currently in progress.
  PathTimeframeGroup? _referenceMonthFor(List<PathTimeframeGroup> months) {
    for (final month in months) {
      if (month.isCurrent) return month;
    }
    for (final month in months.reversed) {
      if (!month.isLocked && month.completed < month.total) return month;
    }
    return null;
  }

  /// Jumps straight into the month's first not-yet-completed step (or its
  /// first step at all, if every step is already done) — there is no more
  /// intermediate "steps of this month" list screen.
  ///
  /// Awaits the push: [PathStepScreen] pops `true` when a step was just
  /// completed, forwarded to [_hasProgressed] so backing out of this screen
  /// carries the signal up to [PathScreen].
  Future<void> _openTimeframe(
    BuildContext context,
    PathTimeframeGroup month,
  ) async {
    if (month.steps.isEmpty) return;
    final step = month.steps.firstWhere(
      (s) => !s.isCompleted,
      orElse: () => month.steps.first,
    );
    final progressed = await context.push<bool>(
      '/path/benessere/step/${step.id}',
      extra: step,
    );
    if (progressed == true) setState(() => _hasProgressed = true);
  }
}
