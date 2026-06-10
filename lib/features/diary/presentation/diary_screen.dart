import 'package:flutter/material.dart';
import 'package:kilocal_flutter_app/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';

class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.diaryTitle)),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenGutter, vertical: AppSpacing.spaceMd),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.spaceSm),
            child: AppCard(
              onTap: () {},
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: index % 2 == 0 ? AppColors.accentSoft : AppColors.background,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      index % 2 == 0 ? Icons.check_circle : Icons.schedule,
                      color: index % 2 == 0 ? AppColors.accent : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Attività giorno ${index + 1}', style: AppTypography.textTheme.bodyMedium),
                        Text(
                          index % 2 == 0 ? 'Completato' : 'In attesa',
                          style: AppTypography.textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}