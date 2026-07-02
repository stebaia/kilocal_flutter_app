import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
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
  });

  final CmsForm form;
  final Map<String, dynamic> initialValues;
  final bool submitting;
  final ValueChanged<Map<String, dynamic>> onSubmit;

  @override
  State<CmsFormView> createState() => _CmsFormViewState();
}

class _CmsFormViewState extends State<CmsFormView> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String?> _singleSelect = {};
  final Map<String, Set<String>> _multiSelect = {};
  final Map<String, bool> _checkboxes = {};

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
    };
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
        return field.multiple ? _buildMultiSelect(field) : _buildSelect(field);
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
    return TextFormField(
      controller: _controllers[field.key],
      obscureText: field.type == CmsFormFieldType.password,
      keyboardType: _keyboardFor(field.type),
      maxLines: field.type == CmsFormFieldType.textarea ? 4 : 1,
      decoration: InputDecoration(
        labelText: field.label,
        hintText: field.placeholder,
      ),
      validator: (value) => _validate(field, value),
    );
  }

  Widget _buildSelect(CmsFormField field) {
    return DropdownButtonFormField<String>(
      initialValue: _singleSelect[field.key],
      decoration: InputDecoration(labelText: field.label),
      items: [
        for (final option in field.options)
          DropdownMenuItem(value: option.value, child: Text(option.label)),
      ],
      onChanged: (value) => setState(() => _singleSelect[field.key] = value),
      validator: (value) => _validate(field, value),
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
