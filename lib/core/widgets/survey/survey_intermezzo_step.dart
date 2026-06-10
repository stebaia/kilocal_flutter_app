import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../brand_gradient_background.dart';

/// Intermezzo step: full-bleed brand gradient with a centered illustration,
/// title, and a loading indicator.
class SurveyIntermezzoStep extends StatelessWidget {
  const SurveyIntermezzoStep({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return BrandGradientBackground(
      showTopGlow: true,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenGutter),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FlutterLogo(size: 160),
              const SizedBox(height: AppSpacing.spaceLg),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutralWhite,
                ),
              ),
              const SizedBox(height: AppSpacing.spaceMd),
              const CircularProgressIndicator(color: AppColors.neutralWhite),
            ],
          ),
        ),
      ),
    );
  }
}