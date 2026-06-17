import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';

class BenefitCard extends StatelessWidget {
  const BenefitCard({
    super.key,
    required this.partner,
    required this.code,
    required this.detailsLabel,
    this.onTap,
    this.onDetailsPressed,
  });

  final String partner;
  final String code;
  final String detailsLabel;
  final VoidCallback? onTap;
  final VoidCallback? onDetailsPressed;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
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
            child: Text(
              partner[0],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: AppSpacing.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(partner, style: AppTypography.textTheme.titleMedium),
                Text(
                  'Codice: $code',
                  style: AppTypography.textTheme.labelMedium,
                ),
              ],
            ),
          ),
          TextButton(onPressed: onDetailsPressed, child: Text(detailsLabel)),
        ],
      ),
    );
  }
}
