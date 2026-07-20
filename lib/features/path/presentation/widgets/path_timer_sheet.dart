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

/// The hours/minutes/seconds wheels on their own, reporting the selected
/// [Duration] as the user scrolls. Reused by the bottom sheet and by the
/// full-screen timer tool.
class TimerDurationWheels extends StatefulWidget {
  const TimerDurationWheels({
    super.key,
    required this.onChanged,
    this.digitSize,
  });

  final ValueChanged<Duration> onChanged;

  /// Font size of the wheel digits; defaults to the bottom sheet's size.
  final double? digitSize;

  @override
  State<TimerDurationWheels> createState() => _TimerDurationWheelsState();
}

class _TimerDurationWheelsState extends State<TimerDurationWheels> {
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;

  void _notify() => widget.onChanged(
    Duration(hours: _hours, minutes: _minutes, seconds: _seconds),
  );

  double get _itemExtent =>
      widget.digitSize == null ? 48.0 : widget.digitSize! * 1.4;

  double get _columnWidth => widget.digitSize == null ? 64 : 82;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Labels and wheels are laid out as two aligned rows rather than three
    // label-on-top columns: that keeps the wheels a self-contained block, so
    // the digits — not the labels — sit at the centre of the enclosing card.
    final labels = [
      l10n.pathTimerHours,
      l10n.pathTimerMinutes,
      l10n.pathTimerSeconds,
    ];
    final onChanged = <ValueChanged<int>>[
      (v) {
        _hours = v;
        _notify();
      },
      (v) {
        _minutes = v;
        _notify();
      },
      (v) {
        _seconds = v;
        _notify();
      },
    ];
    const maxima = [24, 60, 60];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) _colonSpacer(),
              SizedBox(
                width: _columnWidth,
                child: Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.spaceXs),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) _Colon(height: _itemExtent * 3),
              _WheelColumn(
                max: maxima[i],
                width: _columnWidth,
                itemExtent: _itemExtent,
                digitSize: widget.digitSize,
                onChanged: onChanged[i],
              ),
            ],
          ],
        ),
      ],
    );
  }

  /// Reserves the colon's width in the label row (without its height), so each
  /// label stays centred over its own wheel.
  Widget _colonSpacer() => SizedBox(width: _colonWidth(context));

  /// Width a colon occupies: its glyph plus the padding [_Colon] adds.
  double _colonWidth(BuildContext context) {
    final painter = TextPainter(
      text: TextSpan(
        text: ':',
        style: AppTypography.textTheme.headlineMedium,
      ),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    return painter.width + AppSpacing.space2xs * 2;
  }
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
  Duration _duration = Duration.zero;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: AppSpacing.spaceXl),
        TimerDurationWheels(onChanged: (d) => _duration = d),
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
                    if (_duration > Duration.zero) {
                      Navigator.of(context).pop(_duration);
                    }
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
  const _Colon({required this.height});

  /// Height of the neighbouring wheel, so the colon centres on its middle row.
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space2xs),
          child: Text(
            ':',
            style: AppTypography.textTheme.headlineMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

/// One scrollable digit wheel. Shows three rows: the centred, selected row in
/// ink and its neighbours greyed out.
class _WheelColumn extends StatefulWidget {
  const _WheelColumn({
    required this.max,
    required this.width,
    required this.itemExtent,
    required this.onChanged,
    this.digitSize,
  });

  final int max;
  final double width;
  final double itemExtent;
  final ValueChanged<int> onChanged;

  /// Font size of the wheel digits. Defaults to the sheet's `headlineMedium`.
  final double? digitSize;

  @override
  State<_WheelColumn> createState() => _WheelColumnState();
}

class _WheelColumnState extends State<_WheelColumn> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.itemExtent * 3,
      child: ListWheelScrollView.useDelegate(
        itemExtent: widget.itemExtent,
        perspective: 0.005,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (v) {
          final value = v % widget.max;
          setState(() => _selected = value);
          widget.onChanged(value);
        },
        // Looping: the wheel wraps, so the row above 00 shows the last value
        // instead of blank space and all three rows are always filled.
        childDelegate: ListWheelChildLoopingListDelegate(
          children: [
            for (var index = 0; index < widget.max; index++)
              Center(
                child: Text(
                  index.toString().padLeft(2, '0'),
                  style: AppTypography.textTheme.headlineMedium?.copyWith(
                    fontSize: widget.digitSize,
                    color: index == _selected
                        ? AppColors.textPrimary
                        : AppColors.borderCard,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
