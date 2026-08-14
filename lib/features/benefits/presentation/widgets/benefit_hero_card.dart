import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/benefit.dart';
import '../../../../../core/widgets/cms_image.dart';

/// Large hero card for a primary partner ("Partner Primari" section).
class BenefitHeroCard extends StatelessWidget {
  const BenefitHeroCard({
    super.key,
    required this.benefit,
    required this.detailsLabel,
    this.onDetailsPressed,
  });

  final Benefit benefit;
  final String detailsLabel;
  final VoidCallback? onDetailsPressed;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.spaceSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: benefit.imageUrl != null
                  ? CmsImage(
                      benefit.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_) => const _HeroPlaceholder(),
                    )
                  : const _HeroPlaceholder(),
            ),
          ),
          const SizedBox(height: AppSpacing.spaceMd),
          Text(benefit.name, style: AppTypography.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.spaceMd),
          OutlinedButton(
            onPressed: onDetailsPressed,
            child: Text(detailsLabel),
          ),
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
