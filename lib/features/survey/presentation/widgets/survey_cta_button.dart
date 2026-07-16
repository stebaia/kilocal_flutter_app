import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Full-width pill CTA used at the bottom of every survey step, and for the
/// result screen's kit actions.
///
/// [filled] (default): solid [AppColors.brandPink] with a white label and a
/// white circular forward arrow; disabled renders a muted grey fill (matching
/// the "Continua con il prossimo step" design). [busy] shows a spinner.
/// [SurveyCtaButton.outlined] is the secondary style from the result screen —
/// a white pill with a pink border, label and arrow.
class SurveyCtaButton extends StatelessWidget {
  const SurveyCtaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
  }) : filled = true;

  const SurveyCtaButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
  }) : busy = false,
       filled = false;

  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !busy;
    final radius = BorderRadius.circular(AppRadius.pill);

    final Color background;
    final Color foreground;
    if (!filled) {
      background = AppColors.neutralWhite;
      foreground = enabled ? AppColors.brandPink : AppColors.textSecondary;
    } else {
      background = enabled ? AppColors.brandPink : AppColors.divider;
      foreground = enabled ? AppColors.neutralWhite : AppColors.textSecondary;
    }

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: background,
        borderRadius: radius,
        shape: filled
            ? null
            : RoundedRectangleBorder(
                borderRadius: radius,
                side: BorderSide(color: foreground),
              ),
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spaceMd,
              vertical: AppSpacing.spaceMd,
            ),
            child: busy
                ? const Center(
                    child: SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.neutralWhite,
                      ),
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: foreground,
                          ),
                        ),
                      ),
                      _ArrowBadge(filled: filled, enabled: enabled),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _ArrowBadge extends StatelessWidget {
  const _ArrowBadge({required this.filled, required this.enabled});

  final bool filled;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    // The outlined style inverts the badge: pink disc, white chevron.
    final Color disc;
    final Color chevron;
    if (!filled) {
      disc = enabled ? AppColors.brandPink : AppColors.divider;
      chevron = AppColors.neutralWhite;
    } else {
      disc = enabled
          ? AppColors.neutralWhite
          : AppColors.neutralWhite.withValues(alpha: 0.6);
      chevron = enabled ? AppColors.brandPink : AppColors.textSecondary;
    }

    return Container(
      height: 26,
      width: 26,
      decoration: BoxDecoration(color: disc, shape: BoxShape.circle),
      child: Icon(Icons.chevron_right, size: 20, color: chevron),
    );
  }
}
