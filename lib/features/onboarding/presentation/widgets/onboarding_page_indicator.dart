import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class OnboardingPageIndicator extends StatelessWidget {
  const OnboardingPageIndicator({
    super.key,
    required this.itemCount,
    required this.currentPage,
    this.color = AppColors.accent,
  });

  final int itemCount;
  final int currentPage;

  /// Color of the active dot; inactive dots are a light neutral.
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(itemCount, (index) {
        final isActive = index == currentPage;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? color
                : AppColors.borderCard.withValues(alpha: 0.5),
          ),
        );
      }),
    );
  }
}
