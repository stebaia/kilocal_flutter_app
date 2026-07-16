import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/integrazione_reminder_service.dart';
import '../../domain/entities/integrazione_data.dart';
import '../../domain/entities/reminder_offset.dart';

/// Localized label for a snooze [offset] (e.g. "Posticipa di 2 ore").
String reminderOffsetLabel(AppLocalizations l10n, ReminderOffset offset) {
  return switch (offset) {
    ReminderOffset.hours2 => l10n.integrationReminderSnooze2h,
    ReminderOffset.hours4 => l10n.integrationReminderSnooze4h,
    ReminderOffset.hours8 => l10n.integrationReminderSnooze8h,
    ReminderOffset.day1 => l10n.integrationReminderSnooze1d,
  };
}

/// Lowercase short label for a snooze [offset] (e.g. "posticipa di 2 ore"),
/// used inside "Promemoria attivo: …".
String reminderOffsetShortLabel(AppLocalizations l10n, ReminderOffset offset) {
  return switch (offset) {
    ReminderOffset.hours2 => l10n.integrationReminderSnooze2hShort,
    ReminderOffset.hours4 => l10n.integrationReminderSnooze4hShort,
    ReminderOffset.hours8 => l10n.integrationReminderSnooze8hShort,
    ReminderOffset.day1 => l10n.integrationReminderSnooze1dShort,
  };
}

/// Entry point: opens the reminder flow for [product].
///
/// If a reminder is already scheduled it opens the "edit or delete" hub;
/// otherwise it opens the "add reminder" sheet. Handles the whole flow and
/// leaves the notification scheduled/updated/cancelled accordingly. Returns
/// `true` when the reminder state changed.
Future<bool> showIntegrazioneReminderFlow(
  BuildContext context, {
  required IntegrazioneReminderService service,
  required IntegrazioneProduct product,
}) async {
  final existing = await service.getReminder(product.id);
  if (!context.mounted) return false;

  if (existing == null) {
    return await _showAddSheet(context, service: service, product: product) ??
        false;
  }
  return await _showEditOrDeleteSheet(
        context,
        service: service,
        product: product,
        active: existing,
      ) ??
      false;
}

/// "Aggiungi promemoria": pick an offset, confirm → schedule.
Future<bool?> _showAddSheet(
  BuildContext context, {
  required IntegrazioneReminderService service,
  required IntegrazioneProduct product,
}) {
  final l10n = AppLocalizations.of(context)!;
  return showAppBrandBottomSheet<bool>(
    context,
    title: l10n.integrationReminderAddTitle,
    child: _OffsetPickerBody(
      confirmLabel: l10n.integrationReminderConfirm,
      onConfirm: (context, offset) async {
        final ok = await service.scheduleReminder(
          product: product,
          offset: offset,
        );
        if (context.mounted) Navigator.of(context).pop(ok);
      },
    ),
  );
}

/// "Modifica o elimina promemoria": shows the message + current snooze, with
/// edit/delete actions.
Future<bool?> _showEditOrDeleteSheet(
  BuildContext context, {
  required IntegrazioneReminderService service,
  required IntegrazioneProduct product,
  required ActiveReminder active,
}) {
  final l10n = AppLocalizations.of(context)!;
  return showAppBrandBottomSheet<bool>(
    context,
    title: l10n.integrationReminderEditDeleteTitle,
    child: _EditOrDeleteBody(
      product: product,
      active: active,
      onEdit: (sheetContext) async {
        final changed = await _showEditSheet(
          sheetContext,
          service: service,
          product: product,
        );
        if (sheetContext.mounted && changed == true) {
          Navigator.of(sheetContext).pop(true);
        }
      },
      onDelete: (sheetContext) async {
        final confirmed = await _showDeleteConfirmSheet(sheetContext);
        if (confirmed == true) {
          await service.cancelReminder(product.id);
          if (sheetContext.mounted) Navigator.of(sheetContext).pop(true);
        }
      },
    ),
  );
}

/// "Modifica promemoria": pick a new offset, save.
Future<bool?> _showEditSheet(
  BuildContext context, {
  required IntegrazioneReminderService service,
  required IntegrazioneProduct product,
}) {
  final l10n = AppLocalizations.of(context)!;
  return showAppBrandBottomSheet<bool>(
    context,
    title: l10n.integrationReminderEditTitle,
    child: _OffsetPickerBody(
      confirmLabel: l10n.integrationReminderSave,
      showCancel: true,
      onConfirm: (context, offset) async {
        final ok = await service.scheduleReminder(
          product: product,
          offset: offset,
        );
        if (context.mounted) Navigator.of(context).pop(ok);
      },
    ),
  );
}

/// "Sicuro di voler eliminare...": confirm deletion.
Future<bool?> _showDeleteConfirmSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return showAppBrandBottomSheet<bool>(
    context,
    title: l10n.integrationReminderEditTitle,
    child: _DeleteConfirmBody(),
  );
}

/// Shared body: an expandable "Seleziona orario" dropdown listing the snooze
/// offsets, with a confirm button (enabled once an option is picked).
class _OffsetPickerBody extends StatefulWidget {
  const _OffsetPickerBody({
    required this.confirmLabel,
    required this.onConfirm,
    this.showCancel = false,
  });

  final String confirmLabel;
  final bool showCancel;
  final Future<void> Function(BuildContext context, ReminderOffset offset)
  onConfirm;

  @override
  State<_OffsetPickerBody> createState() => _OffsetPickerBodyState();
}

class _OffsetPickerBodyState extends State<_OffsetPickerBody> {
  ReminderOffset? _selected;
  bool _expanded = false;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selectedLabel = _selected == null
        ? l10n.integrationReminderSelectTime
        : reminderOffsetLabel(l10n, _selected!);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenGutter),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DropdownField(
            label: selectedLabel,
            expanded: _expanded,
            onTap: () => setState(() => _expanded = !_expanded),
          ),
          if (_expanded)
            _OffsetOptions(
              selected: _selected,
              onSelected: (o) => setState(() {
                _selected = o;
                _expanded = false;
              }),
            ),
          const SizedBox(height: AppSpacing.spaceMd),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: AppSpacing.spaceMd),
          Row(
            children: [
              if (widget.showCancel) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: _busy
                        ? null
                        : () => Navigator.of(context).pop(false),
                    child: Text(l10n.integrationReminderCancel),
                  ),
                ),
                const SizedBox(width: AppSpacing.spaceSm),
              ],
              Expanded(
                child: ElevatedButton(
                  onPressed: (_selected == null || _busy)
                      ? null
                      : () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final errorText = l10n.integrationReminderError;
                          setState(() => _busy = true);
                          try {
                            await widget.onConfirm(context, _selected!);
                          } catch (_) {
                            // Scheduling failed: surface a message and let the
                            // user retry instead of leaving the sheet stuck.
                            if (mounted) {
                              setState(() => _busy = false);
                              messenger.showSnackBar(
                                SnackBar(content: Text(errorText)),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    disabledBackgroundColor: AppColors.divider,
                  ),
                  child: Text(widget.confirmLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.expanded,
    required this.onTap,
  });

  final String label;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceLg,
          vertical: AppSpacing.spaceMd,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: AppColors.textPrimary),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: AppTypography.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: AppSpacing.spaceXs),
            Icon(
              expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _OffsetOptions extends StatelessWidget {
  const _OffsetOptions({required this.selected, required this.onSelected});

  final ReminderOffset? selected;
  final ValueChanged<ReminderOffset> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.spaceSm),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceMd),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.textPrimary),
      ),
      child: Column(
        children: [
          for (final o in ReminderOffset.values)
            _OffsetRow(
              label: reminderOffsetLabel(l10n, o),
              checked: selected == o,
              onTap: () => onSelected(o),
              showDivider: o != ReminderOffset.values.last,
            ),
        ],
      ),
    );
  }
}

class _OffsetRow extends StatelessWidget {
  const _OffsetRow({
    required this.label,
    required this.checked,
    required this.onTap,
    required this.showDivider,
  });

  final String label;
  final bool checked;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.spaceSm),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: checked ? AppColors.accent : AppColors.borderCard,
                      width: 1.5,
                    ),
                    color: checked ? AppColors.accent : Colors.transparent,
                  ),
                  child: checked
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: AppColors.neutralWhite,
                        )
                      : null,
                ),
                const SizedBox(width: AppSpacing.spaceMd),
                Text(label, style: AppTypography.textTheme.bodyLarge),
              ],
            ),
          ),
          if (showDivider) const Divider(height: 1, color: AppColors.divider),
        ],
      ),
    );
  }
}

/// Body of the "edit or delete" hub: message box, current snooze pill, and the
/// Delete / Edit buttons.
class _EditOrDeleteBody extends StatelessWidget {
  const _EditOrDeleteBody({
    required this.product,
    required this.active,
    required this.onEdit,
    required this.onDelete,
  });

  final IntegrazioneProduct product;
  final ActiveReminder active;
  final Future<void> Function(BuildContext context) onEdit;
  final Future<void> Function(BuildContext context) onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenGutter),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ReadonlyBox(text: l10n.integrationReminderMessage(product.title)),
          const SizedBox(height: AppSpacing.spaceMd),
          _ReadonlyBox(
            text: l10n.integrationReminderSnoozedLabel(
              reminderOffsetLabel(l10n, active.offset),
            ),
            muted: true,
            rounded: true,
          ),
          const SizedBox(height: AppSpacing.spaceMd),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: AppSpacing.spaceMd),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => onDelete(context),
                  child: Text(l10n.integrationReminderDelete),
                ),
              ),
              const SizedBox(width: AppSpacing.spaceSm),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => onEdit(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                  ),
                  child: Text(l10n.integrationReminderEdit),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Body of the delete-confirmation sheet.
class _DeleteConfirmBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenGutter),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ReadonlyBox(text: l10n.integrationReminderDeleteConfirm),
          const SizedBox(height: AppSpacing.spaceMd),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: AppSpacing.spaceMd),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(l10n.integrationReminderCancel),
                ),
              ),
              const SizedBox(width: AppSpacing.spaceSm),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                  ),
                  child: Text(l10n.integrationReminderDelete),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReadonlyBox extends StatelessWidget {
  const _ReadonlyBox({
    required this.text,
    this.muted = false,
    this.rounded = false,
  });

  final String text;
  final bool muted;
  final bool rounded;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spaceLg,
        vertical: AppSpacing.spaceMd,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          rounded ? AppRadius.pill : AppRadius.md,
        ),
        border: Border.all(color: AppColors.borderCard),
      ),
      child: Text(
        text,
        textAlign: rounded ? TextAlign.center : TextAlign.start,
        style: AppTypography.textTheme.bodyLarge?.copyWith(
          color: muted ? AppColors.textSecondary : AppColors.textPrimary,
        ),
      ),
    );
  }
}
