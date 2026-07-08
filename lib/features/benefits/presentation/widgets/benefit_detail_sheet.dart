import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../survey/presentation/widgets/survey_html.dart';
import '../../domain/entities/benefit.dart';

/// Opens the benefit detail in a brand bottom sheet (red header reused from the
/// timer sheet). Pops with `true` when the user taps the reward CTA, so the
/// caller can open the external offer url; `null`/`false` when dismissed.
Future<bool?> showBenefitDetailSheet(BuildContext context, Benefit benefit) {
  final l10n = AppLocalizations.of(context)!;
  return showAppBrandBottomSheet<bool>(
    context,
    title: benefit.name,
    child: _BenefitDetailContent(benefit: benefit, l10n: l10n),
  );
}

/// Body of the benefit detail sheet: hero image, description and reward CTA.
class _BenefitDetailContent extends StatelessWidget {
  const _BenefitDetailContent({required this.benefit, required this.l10n});

  final Benefit benefit;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenGutter,
        AppSpacing.spaceLg,
        AppSpacing.screenGutter,
        AppSpacing.spaceMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: benefit.imageUrl != null
                  ? Image.network(
                      benefit.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const _HeroPlaceholder(),
                    )
                  : const _HeroPlaceholder(),
            ),
          ),
          if (benefit.description != null) ...[
            const SizedBox(height: AppSpacing.spaceLg),
            SurveyHtml(html: benefit.description!, lineHeight: 1.4),
          ],
          if (benefit.ctaUrl != null) ...[
            const SizedBox(height: AppSpacing.spaceLg),
            const Divider(),
            const SizedBox(height: AppSpacing.spaceMd),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.card_giftcard),
              label: Text(l10n.benefitClaimReward),
            ),
          ],
        ],
      ),
    );
  }
}

class _HeroPlaceholder extends StatelessWidget {
  const _HeroPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.accentSoft,
      alignment: Alignment.center,
      child: const Icon(Icons.card_giftcard, color: AppColors.accent, size: 40),
    );
  }
}
