import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../domain/entities/promemoria_reminder.dart';

/// Week view: a 7-day strip (day numbers, selected day highlighted) with the
/// reminders of each day stacked as chips in per-day columns.
class PromemoriaCalendarView extends StatefulWidget {
  const PromemoriaCalendarView({
    super.key,
    required this.month,
    required this.reminders,
    required this.onTap,
  });

  /// Focused month; the shown week is anchored to today when today is in this
  /// month, otherwise to the first day with a reminder, otherwise the 1st.
  final DateTime month;
  final List<PromemoriaReminder> reminders;
  final ValueChanged<PromemoriaReminder> onTap;

  @override
  State<PromemoriaCalendarView> createState() => _PromemoriaCalendarViewState();
}

class _PromemoriaCalendarViewState extends State<PromemoriaCalendarView> {
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _selected = _anchorDay();
  }

  @override
  void didUpdateWidget(PromemoriaCalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-anchor when the month changes.
    if (oldWidget.month.year != widget.month.year ||
        oldWidget.month.month != widget.month.month) {
      _selected = _anchorDay();
    }
  }

  DateTime _anchorDay() {
    final now = DateTime.now();
    if (now.year == widget.month.year && now.month == widget.month.month) {
      return DateTime(now.year, now.month, now.day);
    }
    if (widget.reminders.isNotEmpty) {
      final first = widget.reminders
          .map((r) => r.day)
          .reduce((a, b) => a.isBefore(b) ? a : b);
      return first;
    }
    return DateTime(widget.month.year, widget.month.month, 1);
  }

  /// The Monday-based week (7 days) containing [_selected].
  List<DateTime> get _week {
    final monday = _selected.subtract(Duration(days: _selected.weekday - 1));
    return List.generate(
      7,
      (i) => DateTime(monday.year, monday.month, monday.day + i),
    );
  }

  List<PromemoriaReminder> _remindersOn(DateTime day) => widget.reminders
      .where(
        (r) =>
            r.day.year == day.year &&
            r.day.month == day.month &&
            r.day.day == day.day,
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    final week = _week;
    final today = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day-number strip — grey band.
        Container(
          color: AppColors.calendarColumn,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.spaceSm),
          child: Row(
            children: [
              for (final day in week)
                Expanded(
                  child: _DayCell(
                    day: day,
                    selected: _isSameDay(day, _selected),
                    isToday: _isSameDay(day, today),
                    onTap: () => setState(() => _selected = day),
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: 0.5, color: AppColors.dividerStrong),
        // Per-day columns of reminder chips (white), dividers to the bottom.
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final day in week)
                Expanded(
                  child: Container(
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border(
                        right: day == week.last
                            ? BorderSide.none
                            : const BorderSide(color: AppColors.divider, width: 0.5),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: AppSpacing.spaceXs,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          for (final r in _remindersOn(day))
                            _ReminderChip(
                              reminder: r,
                              onTap: () => widget.onTap(r),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.selected,
    required this.isToday,
    required this.onTap,
  });

  final DateTime day;
  final bool selected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.accent : Colors.transparent,
            shape: BoxShape.circle,
            border: isToday && !selected
                ? Border.all(color: AppColors.accent)
                : null,
          ),
          child: Text(
            '${day.day}',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: selected ? AppColors.neutralWhite : AppColors.textPrimary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _ReminderChip extends StatelessWidget {
  const _ReminderChip({required this.reminder, required this.onTap});

  final PromemoriaReminder reminder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: AppSpacing.spaceXs),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceXs,
          vertical: AppSpacing.space2xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.borderCard),
        ),
        child: Text(
          reminder.message,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.textTheme.labelMedium?.copyWith(
            fontSize: 10,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
