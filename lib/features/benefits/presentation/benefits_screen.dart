import 'package:flutter/material.dart';
import 'package:kilocal_flutter_app/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';

class BenefitsScreen extends StatelessWidget {
  const BenefitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.benefitsTitle)),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenGutter, vertical: AppSpacing.spaceMd),
        itemCount: 4,
        itemBuilder: (context, index) {
          final partners = ['Twitch', 'Spotify', 'Refeego', 'Nike'];
          final codes = ['TWITCH10', 'SPOT20', 'REFEEGO5', 'NIKE15'];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.spaceSm),
            child: AppCard(
              onTap: () {},
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    alignment: Alignment.center,
                    child: Text(partners[index][0], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: AppSpacing.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(partners[index], style: AppTypography.textTheme.titleMedium),
                        Text('Codice: ${codes[index]}', style: AppTypography.textTheme.labelMedium),
                      ],
                    ),
                  ),
                  TextButton(onPressed: () {}, child: Text(AppLocalizations.of(context)!.benefitDetails)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}