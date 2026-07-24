import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import 'survey_cta_button.dart';
import 'survey_stepper.dart';

/// Shared chrome for survey steps: a brand-gradient header with a convex arc
/// bottom edge (via [_HeaderArcClipper]) carrying the segmented [SurveyStepper]
/// and the
/// step label, a scrollable body, and a pinned bottom CTA. Matches the design.
class SurveyScaffold extends StatelessWidget {
  const SurveyScaffold({
    super.key,
    required this.totalSteps,
    required this.currentIndex,
    required this.stepLabel,
    required this.child,
    required this.ctaLabel,
    required this.onCta,
    this.ctaEnabled = true,
    this.busy = false,
    this.onBack,
    this.onSkip,
    this.errorMessage,
  });

  final int totalSteps;
  final int currentIndex;
  final String? stepLabel;
  final Widget child;
  final String ctaLabel;
  final VoidCallback? onCta;
  final bool ctaEnabled;
  final bool busy;
  final VoidCallback? onBack;
  final VoidCallback? onSkip;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _Header(
            totalSteps: totalSteps,
            currentIndex: currentIndex,
            stepLabel: stepLabel,
            onBack: onBack,
            onSkip: onSkip,
          ),
          SizedBox(height: AppSpacing.spaceMd),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenGutter,
                AppSpacing.spaceXl,
                AppSpacing.screenGutter,
                AppSpacing.spaceLg,
              ),
              child: child,
            ),
          ),
          _Footer(
            ctaLabel: ctaLabel,
            onCta: ctaEnabled && !busy ? onCta : null,
            busy: busy,
            errorMessage: errorMessage,
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.totalSteps,
    required this.currentIndex,
    required this.stepLabel,
    this.onBack,
    this.onSkip,
  });

  final int totalSteps;
  final int currentIndex;
  final String? stepLabel;
  final VoidCallback? onBack;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: const _HeaderArcClipper(arcHeight: 28),
      child: Container(
        decoration: const BoxDecoration(gradient: AppColors.brandGradient),
        padding: const EdgeInsets.only(bottom: AppSpacing.spaceMd),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenGutter,
              AppSpacing.spaceXs,
              AppSpacing.screenGutter,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (onBack != null || onSkip != null)
                  SizedBox(
                    height: 28,
                    child: Row(
                      children: [
                        if (onBack != null)
                          GestureDetector(
                            onTap: onBack,
                            child: const Icon(
                              Icons.arrow_back,
                              color: AppColors.neutralWhite,
                              size: 22,
                            ),
                          ),
                        const Spacer(),
                        if (onSkip != null)
                          GestureDetector(
                            onTap: onSkip,
                            child: const Text(
                              'Salta',
                              style: TextStyle(
                                color: AppColors.neutralWhite,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                const SizedBox(height: AppSpacing.spaceXs),
                SurveyStepper(total: totalSteps, currentIndex: currentIndex),
                if (stepLabel != null) ...[
                  const SizedBox(height: AppSpacing.spaceXs),
                  Text(
                    stepLabel!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutralWhite,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.spaceMd),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.ctaLabel,
    required this.onCta,
    required this.busy,
    this.errorMessage,
  });

  final String ctaLabel;
  final VoidCallback? onCta;
  final bool busy;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenGutter,
          AppSpacing.spaceXs,
          AppSpacing.screenGutter,
          AppSpacing.spaceSm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (errorMessage != null) ...[
              Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 18,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: AppSpacing.spaceXs),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.spaceXs),
            ],
            SurveyCtaButton(label: ctaLabel, onPressed: onCta, busy: busy),
          ],
        ),
      ),
    );
  }
}

/// Clips the header's **bottom** edge with a convex arc that dips lowest at the
/// centre (matches the survey design). [arcHeight] is how far the centre bulges
/// below the side edges.
class _HeaderArcClipper extends CustomClipper<Path> {
  const _HeaderArcClipper({this.arcHeight = 28});

  final double arcHeight;

  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height - arcHeight)
      ..quadraticBezierTo(
        size.width / 2,
        size.height + arcHeight,
        size.width,
        size.height - arcHeight,
      )
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant _HeaderArcClipper oldClipper) =>
      oldClipper.arcHeight != arcHeight;
}
