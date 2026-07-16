import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/di.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../domain/entities/promemoria_reminder.dart';
import 'cubit/promemoria_cubit.dart';
import 'widgets/promemoria_calendar_view.dart';
import 'widgets/promemoria_create_sheet.dart';
import 'widgets/promemoria_list_view.dart';
import 'widgets/promemoria_month_navigator.dart';

class PromemoriaScreen extends StatelessWidget {
  const PromemoriaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PromemoriaCubit>()..load(),
      child: const _PromemoriaView(),
    );
  }
}

class _PromemoriaView extends StatelessWidget {
  const _PromemoriaView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<PromemoriaCubit>();

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.accent,
        shape: const CircleBorder(
          side: BorderSide(color: AppColors.borderCard),
        ),
        elevation: 2,
        onPressed: () => _onAdd(context, cubit),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<PromemoriaCubit, PromemoriaState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppHeader(
                  title: l10n.strumentiPromemoria,
                  showBack: true,
                  trailing: _ViewToggle(
                    view: state.view,
                    onTap: cubit.toggleView,
                  ),
                ),
                Expanded(
                  child: _ReminderPanel(
                    header: PromemoriaMonthNavigator(
                      month: state.focusedMonth,
                      onPrevious: cubit.previousMonth,
                      onNext: cubit.nextMonth,
                    ),
                    child: _body(context, state, cubit),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    PromemoriaState state,
    PromemoriaCubit cubit,
  ) {
    if (state.status == PromemoriaStatus.loading ||
        state.status == PromemoriaStatus.initial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == PromemoriaStatus.error) {
      final l10n = AppLocalizations.of(context)!;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenGutter),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.promemoriaLoadError,
                textAlign: TextAlign.center,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.spaceMd),
              TextButton(onPressed: cubit.load, child: Text(l10n.retry)),
            ],
          ),
        ),
      );
    }

    final monthReminders = state.remindersInMonth;
    if (monthReminders.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenGutter),
          child: Text(
            l10n.promemoriaEmpty,
            textAlign: TextAlign.center,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    switch (state.view) {
      case PromemoriaView.list:
        return PromemoriaListView(
          month: state.focusedMonth,
          reminders: monthReminders,
          onTap: (r) => _onReminderTap(context, cubit, r),
        );
      case PromemoriaView.calendar:
        return PromemoriaCalendarView(
          month: state.focusedMonth,
          reminders: monthReminders,
          onTap: (r) => _onReminderTap(context, cubit, r),
        );
    }
  }

  Future<void> _onAdd(BuildContext context, PromemoriaCubit cubit) async {
    final input = await showPromemoriaCreateSheet(context);
    if (input != null) await cubit.add(input);
  }

  Future<void> _onReminderTap(
    BuildContext context,
    PromemoriaCubit cubit,
    PromemoriaReminder reminder,
  ) async {
    final result = await showPromemoriaEditSheet(context, reminder);
    switch (result) {
      case PromemoriaSaved(:final input):
        await cubit.update(reminder, input);
      case PromemoriaDeleteRequested():
        if (!context.mounted) return;
        final confirmed = await showPromemoriaDeleteConfirmSheet(context);
        if (confirmed == true) await cubit.delete(reminder);
      case null:
        break;
    }
  }
}

/// White rounded panel (navigator + body) sitting on the brand red ellipse
/// header that peeks out behind its top rounded corners.
class _ReminderPanel extends StatelessWidget {
  const _ReminderPanel({required this.header, required this.child});

  final Widget header;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Brand red ellipse behind everything, at the very top of the stack.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SvgPicture.asset(
            'assets/path_header_ellipse.svg',
            fit: BoxFit.fitWidth,
            height: 200,
            alignment: Alignment.topCenter,
          ),
        ),
        // The panel content sits on top of the ellipse, pushed down just
        // enough for the ellipse's top arc to peek above it. It owns its own
        // rounded top + 1px hairline border (the "table" frame); the stack
        // above does not account for that border.
        Padding(
          // No bottom padding: the panel runs to the bottom edge of the
          // screen with no bottom border (the body is "unlimited"). Only the
          // top corners are rounded; the side borders run down off-screen.
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.spaceLg,
            AppSpacing.spaceLg,
            AppSpacing.spaceLg,
            0,
          ),
          // The hairline frame is a foregroundDecoration so it paints *on top*
          // of the child backgrounds (day strip, columns, day headers) — a
          // plain border would be covered by their edge-to-edge fills.
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.lg),
              ),
            ),
            foregroundDecoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.lg),
              ),
              // Top + left + right only; no bottom border.
              border: Border(
                top: BorderSide(color: AppColors.dividerStrong, width: 0.5),
                left: BorderSide(color: AppColors.dividerStrong, width: 0.5),
                right: BorderSide(color: AppColors.dividerStrong, width: 0.5),
              ),
            ),
            child: Column(
              children: [
                header,
                const Divider(height: 0.5, color: AppColors.dividerStrong),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// The "Lista" / "Calendario" toggle pill shown in the header trailing slot.
class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.view, required this.onTap});

  final PromemoriaView view;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Show the label of the view you can switch *to*.
    final label = view == PromemoriaView.list
        ? l10n.promemoriaViewCalendar
        : l10n.promemoriaViewList;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceMd,
          vertical: AppSpacing.spaceXs,
        ),
        decoration: BoxDecoration(
          color: AppColors.accentSoft,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          label,
          style: AppTypography.textTheme.labelMedium?.copyWith(
            color: AppColors.accent,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
