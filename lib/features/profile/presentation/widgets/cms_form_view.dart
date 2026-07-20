import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/cms_form.dart';

/// Generic renderer for a [CmsForm] parsed from the CMS FormKit schema.
///
/// Builds a [Form] with one input per [CmsFormField], applies basic validation
/// derived from the FormKit `validation` expression, and calls [onSubmit] with a
/// `key -> value` map when the form is valid. Values are [String] for text/
/// select fields and `List<String>` for multi-selects. [initialValues] pre-fills
/// fields (e.g. from `user_details`).
class CmsFormView extends StatefulWidget {
  const CmsFormView({
    super.key,
    required this.form,
    required this.onSubmit,
    this.initialValues = const {},
    this.submitting = false,
    this.collapseMultiSelects = false,
  });

  final CmsForm form;
  final Map<String, dynamic> initialValues;
  final bool submitting;
  final ValueChanged<Map<String, dynamic>> onSubmit;

  /// When true, multi-selects list only the options the user actually picked and
  /// hide the full catalogue behind an expandable checkbox list. Opt-in: the
  /// food-preferences tab sets it so the screen reads as "your intolerances",
  /// not "every intolerance that exists". Other CMS forms keep the flat chips.
  final bool collapseMultiSelects;

  @override
  State<CmsFormView> createState() => _CmsFormViewState();
}

class _CmsFormViewState extends State<CmsFormView> {
  /// Identity fields the user must not be able to edit (name, surname, gender):
  /// they are rendered read-only and excluded from the submitted values.
  static const _readOnlyKeys = {'first_name', 'last_name', 'gender'};

  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String?> _singleSelect = {};
  final Map<String, Set<String>> _multiSelect = {};
  final Map<String, bool> _checkboxes = {};

  bool _isReadOnly(CmsFormField field) => _readOnlyKeys.contains(field.key);

  @override
  void initState() {
    super.initState();
    for (final field in widget.form.fields) {
      final initial = widget.initialValues[field.key];
      switch (field.type) {
        case CmsFormFieldType.checkbox:
          _checkboxes[field.key] = initial == true || initial == 'true';
        case CmsFormFieldType.select:
          if (field.multiple) {
            _multiSelect[field.key] = _asStringSet(initial);
          } else {
            _singleSelect[field.key] = initial?.toString();
          }
        default:
          _controllers[field.key] = TextEditingController(
            text: initial?.toString() ?? '',
          );
      }
    }
  }

  Set<String> _asStringSet(dynamic value) {
    if (value is List) return value.map((e) => e.toString()).toSet();
    if (value is String && value.isNotEmpty) return {value};
    return <String>{};
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final values = <String, dynamic>{
      for (final e in _controllers.entries) e.key: e.value.text,
      for (final e in _singleSelect.entries) e.key: e.value ?? '',
      for (final e in _multiSelect.entries) e.key: e.value.toList(),
      for (final e in _checkboxes.entries) e.key: e.value,
    }..removeWhere((key, _) => _readOnlyKeys.contains(key));
    widget.onSubmit(values);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final field in widget.form.fields) ...[
            _buildField(field),
            const SizedBox(height: AppSpacing.spaceMd),
          ],
          const SizedBox(height: AppSpacing.spaceXs),
          ElevatedButton(
            onPressed: widget.submitting ? null : _submit,
            child: widget.submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(widget.form.submitLabel ?? 'Salva'),
          ),
        ],
      ),
    );
  }

  Widget _buildField(CmsFormField field) {
    switch (field.type) {
      case CmsFormFieldType.checkbox:
        return _buildCheckbox(field);
      case CmsFormFieldType.select:
        if (!field.multiple) return _buildSelect(field);
        return widget.collapseMultiSelects
            ? _buildCollapsibleMultiSelect(field)
            : _buildMultiSelect(field);
      case CmsFormFieldType.text:
      case CmsFormFieldType.email:
      case CmsFormFieldType.number:
      case CmsFormFieldType.password:
      case CmsFormFieldType.tel:
      case CmsFormFieldType.textarea:
      case CmsFormFieldType.date:
        return _buildTextField(field);
    }
  }

  Widget _buildTextField(CmsFormField field) {
    final readOnly = _isReadOnly(field);
    final isEmpty = (_controllers[field.key]?.text.trim() ?? '').isEmpty;
    return TextFormField(
      controller: _controllers[field.key],
      readOnly: readOnly,
      enabled: !readOnly,
      obscureText: field.type == CmsFormFieldType.password,
      keyboardType: _keyboardFor(field.type),
      maxLines: field.type == CmsFormFieldType.textarea ? 4 : 1,
      // Editable empty fields repaint their border/label as the user types, so
      // the "to fill in" highlight clears the moment they enter a value.
      onChanged: readOnly ? null : (_) => setState(() {}),
      decoration: _decoration(
        field,
        readOnly: readOnly,
        highlightEmpty: isEmpty,
      ),
      validator: (value) => _validate(field, value),
    );
  }

  Widget _buildSelect(CmsFormField field) {
    final readOnly = _isReadOnly(field);
    final isEmpty = (_singleSelect[field.key] ?? '').isEmpty;
    return DropdownButtonFormField<String>(
      initialValue: _singleSelect[field.key],
      decoration: _decoration(
        field,
        readOnly: readOnly,
        highlightEmpty: isEmpty,
      ),
      items: [
        for (final option in field.options)
          DropdownMenuItem(value: option.value, child: Text(option.label)),
      ],
      onChanged: readOnly
          ? null
          : (value) => setState(() => _singleSelect[field.key] = value),
      validator: (value) => _validate(field, value),
    );
  }

  /// Builds the [InputDecoration] shared by text and select fields, applying the
  /// read-only (muted, non-editable) and "to fill in" (amber) visual states.
  InputDecoration _decoration(
    CmsFormField field, {
    required bool readOnly,
    required bool highlightEmpty,
  }) {
    final highlight = highlightEmpty && !readOnly;
    // Optional fields still get the "to fill in" hint but without an asterisk;
    // required empty ones read as "<label> *" to make the ask explicit.
    final labelSuffix = field.required ? ' *' : '';
    return InputDecoration(
      labelText: field.label == null ? null : '${field.label}$labelSuffix',
      hintText: field.placeholder,
      filled: true,
      fillColor: readOnly
          ? AppColors.fieldReadOnlyFill
          : highlight
          ? AppColors.fieldToFillFill
          : AppColors.surface,
      suffixIcon: readOnly
          ? const Icon(
              Icons.lock_outline,
              size: 18,
              color: AppColors.textSecondary,
            )
          : highlight
          ? const Icon(
              Icons.edit_outlined,
              size: 18,
              color: AppColors.fieldToFillBorder,
            )
          : null,
      enabledBorder: highlight
          ? OutlineInputBorder(
              borderSide: const BorderSide(
                color: AppColors.fieldToFillBorder,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.spaceXs),
            )
          : null,
    );
  }

  Widget _buildMultiSelect(CmsFormField field) {
    final selected = _multiSelect[field.key] ?? <String>{};
    return FormField<Set<String>>(
      initialValue: selected,
      validator: (value) =>
          field.required && (value?.isEmpty ?? true) ? _errorText(field) : null,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (field.label != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.spaceXs),
                child: Text(
                  field.label!,
                  style: AppTypography.textTheme.labelLarge,
                ),
              ),
            Wrap(
              spacing: AppSpacing.spaceXs,
              runSpacing: AppSpacing.spaceXs,
              children: [
                for (final option in field.options)
                  FilterChip(
                    label: Text(option.label),
                    selected: selected.contains(option.value),
                    onSelected: (on) {
                      setState(() {
                        on
                            ? selected.add(option.value)
                            : selected.remove(option.value);
                      });
                      state.didChange(selected);
                    },
                  ),
              ],
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.space2xs),
                child: Text(
                  state.errorText ?? '',
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    color: AppColors.accent,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Multi-select showing only the picked options, with the full option list
  /// collapsed into an [ExpansionTile] of checkboxes. Used by the
  /// food-preferences tab via [CmsFormView.collapseMultiSelects].
  Widget _buildCollapsibleMultiSelect(CmsFormField field) {
    final l10n = AppLocalizations.of(context)!;
    final selected = _multiSelect[field.key] ?? <String>{};
    return FormField<Set<String>>(
      initialValue: selected,
      validator: (value) =>
          field.required && (value?.isEmpty ?? true) ? _errorText(field) : null,
      builder: (state) {
        void toggle(String value, bool on) {
          setState(() => on ? selected.add(value) : selected.remove(value));
          state.didChange(selected);
        }

        final chosen = field.options
            .where((o) => selected.contains(o.value))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (field.label != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.spaceXs),
                child: Text(
                  field.label!,
                  style: AppTypography.textTheme.labelLarge,
                ),
              ),
            if (chosen.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.spaceXs),
                child: Text(
                  l10n.profileFoodPreferencesEmpty,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.spaceXs),
                child: Wrap(
                  spacing: AppSpacing.spaceXs,
                  runSpacing: AppSpacing.spaceXs,
                  children: [
                    for (final option in chosen)
                      InputChip(
                        label: Text(option.label),
                        onDeleted: () => toggle(option.value, false),
                      ),
                  ],
                ),
              ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.borderCard),
              ),
              child: Theme(
                // ExpansionTile draws its own divider lines; drop them so only
                // the container's own border outlines the white panel.
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  backgroundColor: AppColors.surface,
                  collapsedBackgroundColor: AppColors.surface,
                  // Round the tile's own ink/background to match the container,
                  // so its white fill stops short of the border at the corners.
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  collapsedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.spaceSm,
                  ),
                  childrenPadding: const EdgeInsets.only(
                    left: AppSpacing.spaceSm,
                    right: AppSpacing.spaceSm,
                    bottom: AppSpacing.spaceXs,
                  ),
                  title: Text(
                    l10n.profileFoodPreferencesEdit,
                    style: AppTypography.textTheme.labelLarge,
                  ),
                  children: [
                    for (final option in field.options)
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                        value: selected.contains(option.value),
                        title: Text(option.label),
                        onChanged: (on) => toggle(option.value, on ?? false),
                      ),
                  ],
                ),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.space2xs),
                child: Text(
                  state.errorText ?? '',
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    color: AppColors.accent,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildCheckbox(CmsFormField field) {
    return FormField<bool>(
      initialValue: _checkboxes[field.key],
      validator: (value) =>
          field.required && !(value ?? false) ? _errorText(field) : null,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: _checkboxes[field.key] ?? false,
                  onChanged: (value) {
                    setState(() => _checkboxes[field.key] = value ?? false);
                    state.didChange(value);
                  },
                ),
                Expanded(child: Text(field.label ?? '')),
              ],
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.spaceSm),
                child: Text(
                  state.errorText ?? '',
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    color: AppColors.accent,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  TextInputType? _keyboardFor(CmsFormFieldType type) {
    switch (type) {
      case CmsFormFieldType.email:
        return TextInputType.emailAddress;
      case CmsFormFieldType.number:
        return TextInputType.number;
      case CmsFormFieldType.tel:
        return TextInputType.phone;
      default:
        return null;
    }
  }

  /// Minimal FormKit validation: enforces `required` and a basic email check.
  /// Richer rules can be added as the CMS uses them.
  String? _validate(CmsFormField field, String? value) {
    final v = value?.trim() ?? '';
    if (field.required && v.isEmpty) return _errorText(field);
    if (field.type == CmsFormFieldType.email && v.isNotEmpty) {
      final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
      if (!emailRegex.hasMatch(v)) return _errorText(field);
    }
    return null;
  }

  String _errorText(CmsFormField field) =>
      field.validationLabel ?? '${field.label ?? ''} non valido';
}
