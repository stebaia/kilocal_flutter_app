import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../l10n/app_localizations.dart';

/// Opens the timer duration picker in a brand bottom sheet. Returns the chosen
/// [Duration] when the user taps "start", or `null` if dismissed. The running
/// countdown is shown as a persistent pill on the host screen, not here.
Future<Duration?> showPathTimerSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return showAppBrandBottomSheet<Duration>(
    context,
    title: l10n.pathTimerSetTitle,
    child: const TimerPickerContent(),
  );
}

/// The timer picker body: hours/minutes/seconds wheels plus close/start
/// actions. A standalone widget so it can be dropped into any container; it
/// pops the enclosing route with the chosen [Duration].
class TimerPickerContent extends StatefulWidget {
  const TimerPickerContent({super.key});

  @override
  State<TimerPickerContent> createState() => _TimerPickerContentState();
}

class _TimerPickerContentState extends State<TimerPickerContent> {
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
