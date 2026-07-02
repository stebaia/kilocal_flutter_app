import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Segmented progress indicator shown in the survey header.
///
/// One pill segment per step: completed segments are solid white, the current
/// one is dark ([AppColors.ink]), and upcoming ones are translucent white.
/// Matches the survey design.
class SurveyStepper extends StatelessWidget {
  const SurveyStepper({
    super.key,
    required this.total,
    required this.currentIndex,
  });

  final int total;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    if (total <= 0) return const SizedBox.shrink();

    return Row(
      children: [
        for (var i = 0; i < total; i++) ...[
          Expanded(child: _Segment(state: _stateFor(i))),
          if (i != total - 1) const SizedBox(width: AppSpacing.space2xs),
        ],
      ],
    );
  }

  _SegmentState _stateFor(int i) {
    if (i < currentIndex) return _SegmentState.completed;
    if (i == currentIndex) return _SegmentState.current;
    return _SegmentState.upcoming;
  }
}

enum _SegmentState { completed, current, upcoming }

class _Segment extends StatelessWidget {
  const _Segment({required this.state});

  final _SegmentState state;

  @override
  Widget build(BuildContext context) {
    final Color color;
    switch (state) {
      case _SegmentState.completed:
        color = AppColors.neutralWhite;
      case _SegmentState.current:
        color = AppColors.ink;
      case _SegmentState.upcoming:
        color = AppColors.neutralWhite.withValues(alpha: 0.35);
    }

    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
    );
  }
}
