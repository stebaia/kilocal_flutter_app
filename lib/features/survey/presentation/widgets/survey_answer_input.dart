import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/survey_step.dart';

/// A pill-shaped selectable option used for radio and checkbox questions
/// (matches the wireframe "Risposta preimpostata" chips).
class SurveyOptionChip extends StatelessWidget {
  const SurveyOptionChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceMd,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.surface,
          border: Border.all(color: AppColors.accent, width: 1.5),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.neutralWhite : AppColors.accent,
          ),
        ),
      ),
    );
  }
}

/// The list of options for a radio/checkbox question, with support for the
/// `is_other` free-text field and the `warning_when_selected` notice.
class SurveyOptionsList extends StatelessWidget {
  const SurveyOptionsList({
    super.key,
    required this.options,
    required this.selectedIds,
    required this.onToggle,
    this.otherValue,
    this.onOtherChanged,
    this.otherFieldKey,
  });

  final List<SurveyOption> options;
  final List<String> selectedIds;
  final ValueChanged<SurveyOption> onToggle;
  final String? otherValue;
  final ValueChanged<String>? onOtherChanged;

  /// Key for the free-text "Specifica" field, so consecutive questions with an
  /// `is_other` option don't reuse the previous step's field state.
  final Key? otherFieldKey;

  @override
  Widget build(BuildContext context) {
    final warnings = options
        .where(
          (o) =>
              selectedIds.contains(o.id) &&
              (o.warningWhenSelected?.isNotEmpty ?? false),
        )
        .map((o) => o.warningWhenSelected!)
        .toList();
    final showOther = options.any(
      (o) => o.isOther && selectedIds.contains(o.id),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chips hug their content and stack one per line, left-aligned.
        // Keyed by option id so the AnimatedContainer doesn't reuse the previous
        // step's chip Element (which flashed its old "selected" state for a frame
        // on step change).
        for (final o in options)
          Padding(
            key: ValueKey('survey-chip-${o.id}'),
            padding: const EdgeInsets.only(bottom: AppSpacing.spaceSm),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SurveyOptionChip(
                label: o.text ?? '',
                selected: selectedIds.contains(o.id),
                onTap: () => onToggle(o),
              ),
            ),
          ),
        if (showOther) ...[
          const SizedBox(height: AppSpacing.space2xs),
          SurveyTextField(
            key: otherFieldKey,
            hint: 'Specifica',
            value: otherValue,
            onChanged: onOtherChanged ?? (_) {},
          ),
        ],
        for (final w in warnings) ...[
          const SizedBox(height: AppSpacing.spaceXs),
          _WarningBanner(text: w),
        ],
      ],
    );
  }
}

class _WarningBanner extends StatelessWidget {
  const _WarningBanner({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceSm),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 18, color: AppColors.accent),
          const SizedBox(width: AppSpacing.spaceXs),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dropdown variant of a single-choice question (`show_as_dropdown`).
class SurveyOptionsDropdown extends StatelessWidget {
  const SurveyOptionsDropdown({
    super.key,
    required this.options,
    required this.selectedId,
    required this.onSelected,
    this.hint,
  });

  final List<SurveyOption> options;
  final String? selectedId;
  final ValueChanged<SurveyOption> onSelected;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedId,
      isExpanded: true,
      hint: hint == null ? null : Text(hint!),
      decoration: InputDecoration(
        filled: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceMd,
          vertical: AppSpacing.spaceSm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.accentSoft),
        ),
      ),
      items: [
        for (final o in options)
          DropdownMenuItem(value: o.id, child: Text(o.text ?? '')),
      ],
      onChanged: (id) {
        if (id == null) return;
        onSelected(options.firstWhere((o) => o.id == id));
      },
    );
  }
}

/// A 0..N horizontal scale selector (`type = scale`).
class SurveyScaleInput extends StatelessWidget {
  const SurveyScaleInput({
    super.key,
    required this.from,
    required this.to,
    required this.value,
    required this.onChanged,
    this.initialLabel,
    this.finalLabel,
  });

  final int from;
  final int to;
  final int? value;
  final ValueChanged<int> onChanged;
  final String? initialLabel;
  final String? finalLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if ((initialLabel?.isNotEmpty ?? false) ||
            (finalLabel?.isNotEmpty ?? false))
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.spaceXs),
            child: Text(
              [
                if (initialLabel?.isNotEmpty ?? false) initialLabel,
                if (finalLabel?.isNotEmpty ?? false) finalLabel,
              ].join(' → '),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        for (var i = from; i <= to; i++)
          _ScaleRow(value: i, selected: value == i, onTap: () => onChanged(i)),
      ],
    );
  }
}

class _ScaleRow extends StatelessWidget {
  const _ScaleRow({
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final int value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: AppSpacing.spaceSm),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.spaceSm),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.surface,
          border: Border.all(color: AppColors.accent, width: 1.5),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          '$value',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.neutralWhite : AppColors.accent,
          ),
        ),
      ),
    );
  }
}

/// Free-text / number field for `input` questions (non-date).
class SurveyTextField extends StatefulWidget {
  const SurveyTextField({
    super.key,
    this.hint,
    this.value,
    required this.onChanged,
    this.keyboardType,
    this.inputFormatters,
    this.large = false,
  });

  final String? hint;
  final String? value;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  /// When true, renders the big underline-only style from the design
  /// (large placeholder, red underline). Used for the main free-text answer.
  final bool large;

  @override
  State<SurveyTextField> createState() => _SurveyTextFieldState();
}

class _SurveyTextFieldState extends State<SurveyTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final large = widget.large;
    return TextField(
      
      controller: _controller,
      onChanged: widget.onChanged,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      style: TextStyle(fontSize: large ? 22 : 16, color: AppColors.textPrimary, ),
      decoration: InputDecoration(
        hintText: widget.hint,
        // The global theme fills inputs white; keep survey fields transparent.
        filled: false,
        hintStyle: TextStyle(
          fontSize: large ? 22 : 16,
          color: AppColors.textSecondary,
        ),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: large ? 8 : 4),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.accent),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.accent),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.accent, width: 2),
        ),
      ),
    );
  }
}

/// Date picker field for `input_type = date` questions. Stores ISO
/// `yyyy-MM-dd` (pending backend confirmation of the expected format).
class SurveyDateField extends StatelessWidget {
  const SurveyDateField({
    super.key,
    required this.value,
    required this.onChanged,
    this.hint,
  });

  /// ISO `yyyy-MM-dd`.
  final String? value;
  final ValueChanged<String> onChanged;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final parsed = value == null ? null : DateTime.tryParse(value!);
    final display = parsed == null
        ? (hint ?? 'Seleziona una data')
        : DateFormat('dd/MM/yyyy').format(parsed);

    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: parsed ?? DateTime(now.year - 30),
          firstDate: DateTime(1900),
          lastDate: now,
        );
        if (picked != null) {
          onChanged(DateFormat('yyyy-MM-dd').format(picked));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.spaceSm),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                display,
                style: TextStyle(
                  color: parsed == null
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
