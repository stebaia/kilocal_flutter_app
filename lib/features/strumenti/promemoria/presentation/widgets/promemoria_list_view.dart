import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../domain/entities/promemoria_reminder.dart';

/// List view: every day of the focused month under a header (today is a red
/// pill, other days are a grey band). Days with reminders show their cards
/// below the header. Tapping a card triggers [onTap].
///
/// When the focused month is the current one, the list auto-scrolls so today's
/// header is at the top on first build (and whenever the month changes back to
/// the current one).
class PromemoriaListView extends StatefulWidget {
  const PromemoriaListView({
    super.key,
    required this.month,
    required this.reminders,
    required this.onTap,
  });

  /// First day of the focused month.
  final DateTime month;
  final List<PromemoriaReminder> reminders;
  final ValueChanged<PromemoriaReminder> onTap;

  @override
  State<PromemoriaListView> createState() => _PromemoriaListViewState();
}

class _PromemoriaListViewState extends State<PromemoriaListView> {
  // Key on today's header, used to bring it into view once laid out.
  final _todayKey = GlobalKey();

  // Approximate rendered heights, used only to seed the scroll offset so that
  // today's item is built (a lazy ListView.builder won't build off-screen
  // items, so ensureVisible alone can't find a far-down day). ensureVisible
  // then refines the exact alignment.
  static const _dayHeaderHeight = 45.0;
  static const _reminderCardHeight = 72.0;

  late final ScrollController _controller = ScrollController(
    initialScrollOffset: _estimatedTodayOffset(),
  );

  @override
  void initState() {
    super.initState();
    _scheduleScrollToToday();
  }

  @override
  void didUpdateWidget(PromemoriaListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-align when the user navigates back to the current month.
    if (oldWidget.month != widget.month) _scheduleScrollToToday();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Estimated pixel offset of today's header, summing the heights of every day
  /// above it (each an empty header, plus a card per reminder on that day).
  /// Returns 0 when the focused month isn't the current one.
  double _estimatedTodayOffset() {
    final today = DateTime.now();
    if (widget.month.year != today.year ||
        widget.month.month != today.month) {
      return 0;
    }
    final byDay = <int, int>{};
    for (final r in widget.reminders) {
      byDay.update(r.dateTime.day, (n) => n + 1, ifAbsent: () => 1);
    }
    var offset = 0.0;
    for (var day = 1; day < today.day; day++) {
      offset += _dayHeaderHeight + (byDay[day] ?? 0) * _reminderCardHeight;
    }
    return offset;
  }

  void _scheduleScrollToToday() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_controller.hasClients) return;
      // Seed the position near today so its item is built, then align exactly.
      final estimate = _estimatedTodayOffset().clamp(
        0.0,
        _controller.position.maxScrollExtent,
      );
      _controller.jumpTo(estimate);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = _todayKey.currentContext;
        if (ctx == null) return;
        Scrollable.ensureVisible(
          ctx,
          alignment: 0, // pin today's header to the top of the viewport
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final today = DateTime.now();
    final month = widget.month;

    // Group reminders by day.
    final byDay = <int, List<PromemoriaReminder>>{};
    for (final r in widget.reminders) {
      byDay.putIfAbsent(r.dateTime.day, () => []).add(r);
    }

    // All days of the month, in order.
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    return ListView.builder(
      controller: _controller,
      padding: const EdgeInsets.only(bottom: AppSpacing.spaceXl * 2),
      itemCount: daysInMonth,
      itemBuilder: (context, index) {
        final dayNumber = index + 1;
        final date = DateTime(month.year, month.month, dayNumber);
        final isToday =
            date.year == today.year &&
            date.month == today.month &&
            date.day == today.day;
        final label = DateFormat('EEEE d', locale).format(date);
        final capitalized = '${label[0].toUpperCase()}${label.substring(1)}';
        final dayReminders = byDay[dayNumber] ?? const [];

        return Column(
          key: isToday ? _todayKey : null,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DayHeader(label: capitalized, highlighted: isToday),
            if (dayReminders.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spaceMd,
                  vertical: AppSpacing.spaceSm,
                ),
                child: Column(
                  children: [
                    for (final r in dayReminders)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacing.spaceSm,
                        ),
                        child: _ReminderCard(
                          reminder: r,
                          onTap: () => widget.onTap(r),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.label, required this.highlighted});

  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    if (highlighted) {
      // Grey band with a red pill for today, framed by top/bottom dividers so
      // it lines up with the other day headers.
      return Column(
        children: [
          const Divider(height: 0.5, color: AppColors.dividerStrong),
          Container(
            width: double.infinity,
            color: AppColors.background,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spaceMd,
              vertical: AppSpacing.spaceSm,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spaceMd,
                  vertical: AppSpacing.spaceXs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  label,
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    color: AppColors.neutralWhite,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const Divider(height: 0.5, color: AppColors.dividerStrong),
        ],
      );
    }
    // Grey band with a divider on top and bottom.
    return Column(
      children: [
        const Divider(height: 0.5, color: AppColors.dividerStrong),
        Container(
          width: double.infinity,
          color: AppColors.background,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spaceMd,
            vertical: AppSpacing.spaceSm,
          ),
          child: Text(
            label,
            style: AppTypography.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Divider(height: 0.5, color: AppColors.dividerStrong),
      ],
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.reminder, required this.onTap});

  final PromemoriaReminder reminder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final time = TimeOfDay.fromDateTime(reminder.dateTime).format(context);
    // Past/completed reminders show their time in green.
    final isPast = reminder.dateTime.isBefore(DateTime.now());
    final timeColor = isPast ? AppColors.textPrimary : AppColors.accent;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceLg,
          vertical: AppSpacing.spaceMd,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                reminder.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(width: AppSpacing.spaceMd),
            Text(
              time,
              style: AppTypography.textTheme.labelMedium?.copyWith(
                color: timeColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
