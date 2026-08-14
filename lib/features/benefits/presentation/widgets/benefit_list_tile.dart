import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/benefit.dart';
import '../../../../../core/widgets/cms_image.dart';

/// Compact row for a secondary partner ("Partner Secondari" section).
class BenefitListTile extends StatelessWidget {
  const BenefitListTile({super.key, required this.benefit, this.onTap});

  final Benefit benefit;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          _Logo(url: benefit.logoUrl),
          const SizedBox(width: AppSpacing.spaceMd),
          Expanded(
            child: Text(
              benefit.name,
              style: AppTypography.textTheme.titleMedium,
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textPrimary),
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: SizedBox(
        width: 40,
        height: 40,
        child: url != null
            ? CmsImage(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (_) => const _LogoPlaceholder(),
              )
            : const _LogoPlaceholder(),
      ),
    );
  }
}

class _LogoPlaceholder extends StatelessWidget {
  const _LogoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.accentSoft,
      alignment: Alignment.center,
      child: const Icon(Icons.storefront_outlined, color: AppColors.accent),
    );
  }
}
