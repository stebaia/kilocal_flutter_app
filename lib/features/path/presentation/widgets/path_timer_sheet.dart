import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';

/// Opens the timer duration picker. Returns the chosen [Duration] when the user
/// taps "start", or `null` if the sheet is dismissed. The running countdown is
/// shown as a persistent pill on the host screen, not inside this sheet.
Future<Duration?> showPathTimerSheet(BuildContext context) {
  return showModalBottomSheet<Duration>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    builder: (_) => const _TimerPicker(),
  );
}

class _TimerPicker extends StatefulWidget {
  const _TimerPicker();

  @override
  State<_TimerPicker> createState() => _TimerPickerState();
}

class _TimerPickerState extends State<_TimerPicker> {
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHeader(title: l10n.pathTimerSetTitle),
          const SizedBox(height: AppSpacing.spaceXl),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _WheelColumn(
                label: l10n.pathTimerHours,
                max: 24,
                onChanged: (v) => _hours = v,
              ),
              const _Colon(),
              _WheelColumn(
                label: l10n.pathTimerMinutes,
                max: 60,
                onChanged: (v) => _minutes = v,
              ),
              const _Colon(),
              _WheelColumn(
                label: l10n.pathTimerSeconds,
                max: 60,
                onChanged: (v) => _seconds = v,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceXl),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenGutter,
            ),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.commonClose),
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceSm),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.ink,
                    ),
                    onPressed: () {
                      final d = Duration(
                        hours: _hours,
                        minutes: _minutes,
                        seconds: _seconds,
                      );
                      if (d > Duration.zero) Navigator.of(context).pop(d);
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: Text(l10n.pathTimerStart),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.spaceLg),
        ],
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenGutter,
        AppSpacing.spaceXl,
        AppSpacing.screenGutter,
        AppSpacing.spaceLg,
      ),
      decoration: const BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      child: Text(
        title,
        style: AppTypography.textTheme.titleMedium?.copyWith(
          color: AppColors.neutralWhite,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Colon extends StatelessWidget {
  const _Colon();

  @override
  Widget build(BuildContext context) {
    return Text(
      ':',
      style: AppTypography.textTheme.headlineMedium?.copyWith(
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _WheelColumn extends StatelessWidget {
  const _WheelColumn({
    required this.label,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.textTheme.labelMedium?.copyWith(
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: AppSpacing.spaceXs),
        SizedBox(
          width: 64,
          height: 150,
          child: ListWheelScrollView.useDelegate(
            itemExtent: 48,
            perspective: 0.005,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: onChanged,
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: max,
              builder: (context, index) => Center(
                child: Text(
                  index.toString().padLeft(2, '0'),
                  style: AppTypography.textTheme.headlineMedium,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
