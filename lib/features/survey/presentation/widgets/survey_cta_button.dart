import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Full-width pill CTA used at the bottom of every survey step.
///
/// Enabled: solid [AppColors.accent] with white label and a white circular
/// forward arrow. Disabled: muted grey fill with grey label (matches the
/// "Continua con il prossimo step" design). [busy] shows a spinner.
class SurveyCtaButton extends StatelessWidget {
  const SurveyCtaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !busy;

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: enabled ? AppColors.brandPink : AppColors.divider,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(AppRadius.pill),
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
                            color: enabled
                                ? AppColors.neutralWhite
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      _ArrowBadge(enabled: enabled),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _ArrowBadge extends StatelessWidget {
  const _ArrowBadge({required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      width: 26,
      decoration: BoxDecoration(
        color: enabled
            ? AppColors.neutralWhite
            : AppColors.neutralWhite.withValues(alpha: 0.6),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.chevron_right,
        size: 20,
        color: enabled ? AppColors.brandPink : AppColors.textSecondary,
      ),
    );
  }
}
