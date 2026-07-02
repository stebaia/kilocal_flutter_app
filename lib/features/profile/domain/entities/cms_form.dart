import 'package:equatable/equatable.dart';

/// A CMS-defined form (`forms`) rendered from a FormKit-style schema.
///
/// Each field is a [CmsFormField]; the renderer maps [CmsFormFieldType] to a
/// concrete Flutter input. See [[profile-cms-pages-schema]].
class CmsForm extends Equatable {
  const CmsForm({
    required this.internalName,
    this.submitLabel,
    this.fields = const [],
  });

  final String internalName;
  final String? submitLabel;
  final List<CmsFormField> fields;

  @override
  List<Object?> get props => [internalName, submitLabel, fields];
}

/// The input kind of a [CmsFormField], derived from the FormKit `$formkit`
/// property. Unrecognised kinds fall back to [CmsFormFieldType.text].
enum CmsFormFieldType {
  text,
  email,
  number,
  password,
  tel,
  select,
  checkbox,
  textarea,
  date;

  static CmsFormFieldType fromFormKit(String? value) {
    switch (value) {
      case 'email':
        return CmsFormFieldType.email;
      case 'number':
        return CmsFormFieldType.number;
      case 'password':
        return CmsFormFieldType.password;
      case 'tel':
        return CmsFormFieldType.tel;
      case 'select':
      case 'dropdown':
        return CmsFormFieldType.select;
      case 'checkbox':
        return CmsFormFieldType.checkbox;
      case 'textarea':
        return CmsFormFieldType.textarea;
      case 'date':
        return CmsFormFieldType.date;
      default:
        return CmsFormFieldType.text;
    }
  }
}

/// A single field within a [CmsForm].
class CmsFormField extends Equatable {
  const CmsFormField({
    required this.key,
    required this.type,
    this.label,
    this.placeholder,
    this.validation,
    this.validationLabel,
    this.required = false,
    this.multiple = false,
    this.options = const [],
  });

  final String key;
  final CmsFormFieldType type;
  final String? label;
  final String? placeholder;

  /// Raw FormKit validation expression (e.g. `required|email`).
  final String? validation;
  final String? validationLabel;
  final bool required;

  /// Whether a [CmsFormFieldType.select] accepts multiple values
  /// (FormKit `multiple: true`); such values are stored/sent as a list.
  final bool multiple;

  /// Selectable options for [CmsFormFieldType.select].
  final List<CmsFormFieldOption> options;

  @override
  List<Object?> get props => [
    key,
    type,
    label,
    placeholder,
    validation,
    validationLabel,
    required,
    multiple,
    options,
  ];
}

class CmsFormFieldOption extends Equatable {
  const CmsFormFieldOption({required this.value, required this.label});

  final String value;
  final String label;

  @override
  List<Object?> get props => [value, label];
}
