import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

/// The ‹ Month Year › header row at the top of the white Promemoria panel.
///
/// Not a standalone card — it sits inside [_ReminderPanel] and is separated
/// from the body below by a full-width divider.
class PromemoriaMonthNavigator extends StatelessWidget {
  const PromemoriaMonthNavigator({
    super.key,
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final label = DateFormat('MMMM yyyy', locale).format(month);
    final capitalized = label.isEmpty
        ? label
        : '${label[0].toUpperCase()}${label.substring(1)}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.spaceSm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: AppSpacing.spaceSm),
          Text(
            capitalized,
            style: AppTypography.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: AppSpacing.spaceSm),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right, color: AppColors.textPrimary),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
