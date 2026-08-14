import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../survey/presentation/widgets/survey_html.dart';
import '../../domain/entities/benefit.dart';
import '../../../../../core/widgets/cms_image.dart';

/// Opens the benefit detail in a brand bottom sheet (red header reused from the
/// timer sheet).
///
/// The sheet runs a two-step flow: it first shows the partner description with
/// an "Ottieni il premio" CTA, then swaps in the coupon step (discount code +
/// instructions) with a CTA to the partner site. Pops with `true` only from
/// that second step, so the caller opens the external url after the code has
/// been shown; `null`/`false` when dismissed.
Future<bool?> showBenefitDetailSheet(BuildContext context, Benefit benefit) {
  final l10n = AppLocalizations.of(context)!;
  return showAppBrandBottomSheet<bool>(
    context,
    title: benefit.name,
    child: _BenefitDetailContent(benefit: benefit, l10n: l10n),
  );
}

/// Body of the benefit detail sheet, owning the description → coupon step.
class _BenefitDetailContent extends StatefulWidget {
  const _BenefitDetailContent({required this.benefit, required this.l10n});

  final Benefit benefit;
  final AppLocalizations l10n;

  @override
  State<_BenefitDetailContent> createState() => _BenefitDetailContentState();
}

class _BenefitDetailContentState extends State<_BenefitDetailContent> {
  /// False = partner description step, true = coupon step.
  bool _rewardClaimed = false;

  @override
  Widget build(BuildContext context) {
    final benefit = widget.benefit;
    final l10n = widget.l10n;

    // The coupon step needs something to show: either the code itself or the
    // CMS instructions. Without both, keep the single-step behaviour and send
    // the user straight to the partner site.
    final hasCouponStep =
        benefit.coupon != null || benefit.couponInstructions != null;

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
                  ? CmsImage(
                      benefit.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_) => const _HeroPlaceholder(),
                    )
                  : const _HeroPlaceholder(),
            ),
          ),
          if (_rewardClaimed)
            ..._buildCouponStep(benefit, l10n)
          else
            ..._buildDescriptionStep(benefit, l10n, hasCouponStep),
        ],
      ),
    );
  }

  /// Step 1: partner description + "Ottieni il premio".
  List<Widget> _buildDescriptionStep(
    Benefit benefit,
    AppLocalizations l10n,
    bool hasCouponStep,
  ) {
    return [
      if (benefit.description != null) ...[
        const SizedBox(height: AppSpacing.spaceLg),
        SurveyHtml(html: benefit.description!, lineHeight: 1.4),
      ],
      if (hasCouponStep || benefit.ctaUrl != null) ...[
        const SizedBox(height: AppSpacing.spaceLg),
        const Divider(),
        const SizedBox(height: AppSpacing.spaceMd),
        ElevatedButton.icon(
          onPressed: () {
            if (hasCouponStep) {
              setState(() => _rewardClaimed = true);
            } else {
              // No code to reveal — fall back to opening the partner site.
              Navigator.of(context).pop(true);
            }
          },
          icon: const Icon(Icons.card_giftcard),
          label: Text(l10n.benefitClaimReward),
        ),
      ],
    ];
  }

  /// Step 2: discount code, instructions and the partner-site CTA.
  List<Widget> _buildCouponStep(Benefit benefit, AppLocalizations l10n) {
    return [
      if (benefit.couponInstructions != null) ...[
        const SizedBox(height: AppSpacing.spaceLg),
        SurveyHtml(html: benefit.couponInstructions!, lineHeight: 1.4),
      ],
      if (benefit.coupon != null) ...[
        const SizedBox(height: AppSpacing.spaceLg),
        _CouponChip(code: benefit.coupon!, l10n: l10n),
      ],
      if (benefit.ctaUrl != null) ...[
        const SizedBox(height: AppSpacing.spaceLg),
        const Divider(),
        const SizedBox(height: AppSpacing.spaceMd),
        ElevatedButton.icon(
          onPressed: () => Navigator.of(context).pop(true),
          iconAlignment: IconAlignment.end,
          icon: const Icon(Icons.arrow_forward),
          label: Text(l10n.benefitVisitSite(benefit.name)),
        ),
      ],
    ];
  }
}

/// Outlined pill showing the discount code; tapping it copies the code.
class _CouponChip extends StatelessWidget {
  const _CouponChip({required this.code, required this.l10n});

  final String code;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        await Clipboard.setData(ClipboardData(text: code));
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.benefitCouponCopied)));
      },
      iconAlignment: IconAlignment.end,
      icon: const Icon(Icons.copy, size: 18),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.textPrimary),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.spaceMd),
        shape: const StadiumBorder(),
      ),
      label: Text(
        code,
        style: AppTypography.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
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
