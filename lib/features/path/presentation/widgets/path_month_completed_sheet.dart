import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../statistics/presentation/statistics_screen.dart';

/// Shows the "Complimenti!" sheet after completing the last activity of a
/// month, offering the stats recap instead of leaving the user stranded —
/// there is no more intermediate "steps of this month" screen to fall back
/// onto.
Future<void> showMonthCompletedSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return showAppBrandBottomSheet<void>(
    context,
    title: l10n.pathMonthCompletedTitle,
    child: const _MonthCompletedBody(),
  );
}

class _MonthCompletedBody extends StatelessWidget {
  const _MonthCompletedBody();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenGutter,
        AppSpacing.spaceLg,
        AppSpacing.screenGutter,
        AppSpacing.spaceMd,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const AppIcon(
              AppIcons.chart,
              size: 26,
              color: AppColors.neutralWhite,
            ),
          ),
          const SizedBox(height: AppSpacing.spaceLg),
          Text(
            l10n.pathMonthCompletedBody,
            textAlign: TextAlign.center,
            style: AppTypography.textTheme.bodyLarge?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.spaceLg),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: AppSpacing.spaceLg),
          SizedBox(
            height: 45,
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.accent),
              onPressed: () {
                Navigator.of(context).pop();
                context.push(StatisticsScreen.route);
              },
              child: Text(
                l10n.pathMonthCompletedCta,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
