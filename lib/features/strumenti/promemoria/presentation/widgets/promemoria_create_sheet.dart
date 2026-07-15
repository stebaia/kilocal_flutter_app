import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../domain/entities/promemoria_reminder.dart';

/// Outcome of the reminder sheet: the user either saved [input] (create/edit)
/// or asked to delete the reminder being edited.
sealed class PromemoriaSheetResult {
  const PromemoriaSheetResult();
}

/// The user confirmed create/edit with [input].
class PromemoriaSaved extends PromemoriaSheetResult {
  const PromemoriaSaved(this.input);
  final PromemoriaInput input;
}

/// The user tapped "Elimina" in the edit sheet.
class PromemoriaDeleteRequested extends PromemoriaSheetResult {
  const PromemoriaDeleteRequested();
}

/// Bottom sheet to **create** a reminder: free-text message + date + time.
///
/// Uses the brand-red header sheet (same look as the integration "Attiva
/// promemoria" flow) with inline expandable pickers: tapping "Seleziona data"
/// or "Seleziona orario" reveals a scrollable list right below the field;
/// picking a value collapses it and shows the choice. "Conferma" enables only
/// once message, date and time are all set.
///
/// Returns a [PromemoriaInput], or `null` if cancelled.
Future<PromemoriaInput?> showPromemoriaCreateSheet(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final result = await showAppBrandBottomSheet<PromemoriaSheetResult>(
    context,
    title: l10n.promemoriaAddTitle,
    child: const _PromemoriaEditorBody(),
  );
  return result is PromemoriaSaved ? result.input : null;
}

/// Bottom sheet to **edit** an existing [reminder]: same layout as create, but
/// pre-filled and with "Elimina" / "Modifica" actions instead of "Conferma".
///
/// Returns a [PromemoriaSheetResult] (saved with new input, or delete
/// requested), or `null` if dismissed.
Future<PromemoriaSheetResult?> showPromemoriaEditSheet(
  BuildContext context,
  PromemoriaReminder reminder,
) {
  final l10n = AppLocalizations.of(context)!;
  return showAppBrandBottomSheet<PromemoriaSheetResult>(
    context,
    title: l10n.promemoriaEditTitle,
    child: _PromemoriaEditorBody(initial: reminder),
  );
}

/// Confirmation sheet for deleting a reminder: brand-red "Elimina promemoria"
/// header, a prompt, and Annulla / Elimina actions. Returns `true` if the user
/// confirmed deletion, `false`/`null` otherwise.
Future<bool?> showPromemoriaDeleteConfirmSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return showAppBrandBottomSheet<bool>(
    context,
    title: l10n.promemoriaDeleteTitle,
    child: const _PromemoriaDeleteConfirmBody(),
  );
}

class _PromemoriaDeleteConfirmBody extends StatelessWidget {
  const _PromemoriaDeleteConfirmBody();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenGutter),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.promemoriaDeleteConfirm,
            style: AppTypography.textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.spaceMd),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: AppSpacing.spaceMd),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: const BorderSide(color: AppColors.accent),
                  ),
                  child: Text(l10n.promemoriaCancel),
                ),
              ),
              const SizedBox(width: AppSpacing.spaceSm),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                  ),
                  child: Text(l10n.promemoriaDelete),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Number of selectable days offered starting from today.
const _dayCount = 60;

class _PromemoriaEditorBody extends StatefulWidget {
  const _PromemoriaEditorBody({this.initial});

  /// When set, the sheet is in edit mode: fields are pre-filled and the footer
  /// shows "Elimina"/"Modifica" instead of "Conferma".
  final PromemoriaReminder? initial;

  @override
  State<_PromemoriaEditorBody> createState() => _PromemoriaEditorBodyState();
}

enum _OpenPicker { none, date, time }

class _PromemoriaEditorBodyState extends State<_PromemoriaEditorBody> {
  late final TextEditingController _controller;
  DateTime? _date;
  int? _hour;
  _OpenPicker _open = _OpenPicker.none;

  /// Whether the fields are editable. Create mode is always editable; edit mode
  /// starts read-only and is unlocked by tapping "Modifica".
  late bool _editing;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _editing = initial == null;
    _controller = TextEditingController(text: initial?.message ?? '');
    if (initial != null) {
      _date = DateTime(
        initial.dateTime.year,
        initial.dateTime.month,
        initial.dateTime.day,
      );
      _hour = initial.dateTime.hour;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canConfirm =>
      _controller.text.trim().isNotEmpty && _date != null && _hour != null;

  /// Selectable days: today onward, plus the reminder's own day if it's in the
  /// past (so an existing past reminder keeps a valid, pre-selected date).
  List<DateTime> get _days {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final days = List.generate(_dayCount, (i) => start.add(Duration(days: i)));
    final initialDay = _date;
    if (initialDay != null && initialDay.isBefore(start)) {
      days.insert(0, initialDay);
    }
    return days;
  }

  void _toggle(_OpenPicker picker) {
    if (!_editing) return;
    setState(() => _open = _open == picker ? _OpenPicker.none : picker);
  }

  PromemoriaInput _buildInput() {
    final date = _date!;
    return PromemoriaInput(
      message: _controller.text.trim(),
      dateTime: DateTime(date.year, date.month, date.day, _hour!),
    );
  }

  /// Primary action. In edit mode the first tap ("Modifica") unlocks the fields;
  /// once editing (or in create mode) it confirms/saves.
  void _onPrimaryPressed() {
    if (!_editing) {
      setState(() => _editing = true);
      return;
    }
    Navigator.of(context).pop(PromemoriaSaved(_buildInput()));
  }

  void _delete() {
    Navigator.of(context).pop(const PromemoriaDeleteRequested());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    final dateLabel = _date == null
        ? l10n.promemoriaSelectDate
        : toBeginningOfSentenceCase(
            DateFormat('EEEE d MMMM yyyy', locale).format(_date!),
          );
    final timeLabel = _hour == null
        ? l10n.promemoriaSelectTime
        : '${_hour!.toString().padLeft(2, '0')}:00';

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenGutter),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              enabled: _editing,
              minLines: 3,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(
                color: _editing
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
              decoration: InputDecoration(
                hintText: l10n.promemoriaMessageHint,
                hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                contentPadding: const EdgeInsets.all(AppSpacing.spaceMd),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(color: AppColors.borderCard),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(color: AppColors.borderCard),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(color: AppColors.borderCard),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(color: AppColors.textPrimary),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.spaceLg),
            _DropdownField(
              label: dateLabel,
              active: _open == _OpenPicker.date,
              enabled: _editing,
              onTap: () => _toggle(_OpenPicker.date),
            ),
            if (_open == _OpenPicker.date)
              _OptionsList(
                children: [
                  for (final day in _days)
                    _OptionRow(
                      label: toBeginningOfSentenceCase(
                        DateFormat('EEEE d MMMM yyyy', locale).format(day),
                      ),
                      selected: _date == day,
                      onTap: () => setState(() {
                        _date = day;
                        _open = _OpenPicker.none;
                      }),
                    ),
                ],
              ),
            const SizedBox(height: AppSpacing.spaceMd),
            _DropdownField(
              label: timeLabel,
              active: _open == _OpenPicker.time,
              enabled: _editing,
              onTap: () => _toggle(_OpenPicker.time),
            ),
            if (_open == _OpenPicker.time)
              _OptionsList(
                children: [
                  for (var h = 0; h < 24; h++)
                    _OptionRow(
                      label: '${h.toString().padLeft(2, '0')}:00',
                      selected: _hour == h,
                      onTap: () => setState(() {
                        _hour = h;
                        _open = _OpenPicker.none;
                      }),
                    ),
                ],
              ),
            const SizedBox(height: AppSpacing.spaceLg),
            if (_isEdit) ...[
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: AppSpacing.spaceMd),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _delete,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.accent,
                        side: const BorderSide(color: AppColors.accent),
                      ),
                      child: Text(l10n.promemoriaDelete),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spaceSm),
                  Expanded(
                    child: ElevatedButton(
                      // Read-only: always enabled (unlocks editing). Editing:
                      // enabled only when the fields are valid.
                      onPressed: (!_editing || _canConfirm)
                          ? _onPrimaryPressed
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        disabledBackgroundColor: AppColors.divider,
                        disabledForegroundColor: AppColors.textSecondary,
                      ),
                      child: Text(
                        _editing
                            ? l10n.promemoriaSaveShort
                            : l10n.promemoriaEdit,
                      ),
                    ),
                  ),
                ],
              ),
            ] else
              ElevatedButton(
                onPressed: _canConfirm ? _onPrimaryPressed : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  disabledBackgroundColor: AppColors.divider,
                  disabledForegroundColor: AppColors.textSecondary,
                ),
                child: Text(l10n.promemoriaConfirm),
              ),
          ],
        ),
      ),
    );
  }
}

/// The pill-shaped tappable field. When [active] (its list is open) the label
/// turns brand-red and the chevron points up; otherwise neutral, chevron down.
/// When not [enabled] it is greyed out and ignores taps.
class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.active,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final bool active;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = !enabled
        ? AppColors.textSecondary
        : (active ? AppColors.accent : AppColors.textPrimary);
    final borderColor = enabled ? color : AppColors.borderCard;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceLg,
          vertical: AppSpacing.spaceMd,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.spaceXs),
            Icon(
              active ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 20,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}

/// Scrollable bordered container holding the picker options.
class _OptionsList extends StatelessWidget {
  const _OptionsList({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.spaceSm),
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.accent),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spaceLg,
            vertical: AppSpacing.spaceSm,
          ),
          shrinkWrap: true,
          children: children,
        ),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.spaceSm),
        child: Text(
          label,
          style: AppTypography.textTheme.bodyLarge?.copyWith(
            color: selected ? AppColors.accent : AppColors.textPrimary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
