import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Base layout used by every survey step screen.
/// Provides a scrollable area with title, optional body copy, and a child widget
/// (typically inputs or action buttons).
class SurveyStepLayout extends StatelessWidget {
  const SurveyStepLayout({
    super.key,
    required this.title,
    this.body,
    required this.child,
  });

  final String title;
  final String? body;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        top: kToolbarHeight + AppSpacing.spaceLg,
        left: AppSpacing.screenGutter,
        right: AppSpacing.screenGutter,
        bottom: AppSpacing.spaceLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.textTheme.headlineLarge),
          if (body != null) ...[
            const SizedBox(height: AppSpacing.spaceMd),
            Text(body!, style: AppTypography.textTheme.bodyMedium),
          ],
          const SizedBox(height: AppSpacing.spaceLg),
          child,
        ],
      ),
    );
  }
}