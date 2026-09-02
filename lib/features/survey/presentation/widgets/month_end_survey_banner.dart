import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/survey_answer.dart';

class MonthEndSurveyBanner extends StatelessWidget {
  const MonthEndSurveyBanner({super.key, required this.pending});

  final SurveyMonthEndPending pending;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppCard(
      onTap: () => context.push(
        Uri(
          path: '/survey',
          queryParameters: {'internalName': pending.internalName},
        ).toString(),
      ),
      color: AppColors.accent,
      child: Row(
        children: [
          const Icon(Icons.assignment_outlined, color: AppColors.surface),
          const SizedBox(width: AppSpacing.spaceMd),
          Expanded(
            child: Text(
              l10n.surveyMonthEndCta,
              style: AppTypography.textTheme.titleSmall?.copyWith(
                color: AppColors.surface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.surface),
        ],
      ),
    );
  }
}
