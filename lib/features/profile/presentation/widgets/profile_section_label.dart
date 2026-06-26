import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Gray uppercase-style section label shown above a group of profile cards
/// (e.g. "Il mio Tipo", "Notifiche", "Assistenza").
class ProfileSectionLabel extends StatelessWidget {
  const ProfileSectionLabel({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.textTheme.bodyMedium?.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
