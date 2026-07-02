import '../domain/entities/cms_form.dart';

/// Maps a raw Directus `forms` node (with expanded `fields` →
/// `form_schema_entry`) into a domain [CmsForm].
///
/// The CMS stores each field as a FormKit descriptor: `schema.$formkit` is the
/// input kind and `translations[0]` carries the localized label / placeholder /
/// validation message. Options for select fields come from
/// `translations[0].childs` when present. See [[profile-cms-pages-schema]].
CmsForm mapCmsForm(Map<String, dynamic> json) {
  final rawFields = json['fields'] as List<dynamic>? ?? const [];
  final fields = rawFields
      .map((e) => _mapField(e as Map<String, dynamic>))
      .whereType<CmsFormField>()
      .toList();

  return CmsForm(
    internalName: json['internal_name'] as String? ?? '',
    submitLabel:
        _firstTranslation(json['translations'])?['submit_label'] as String?,
    fields: fields,
  );
}

CmsFormField? _mapField(Map<String, dynamic> junction) {
  // `fields` is a M2M junction: the entry sits under `form_schema_entry_id`.
  final entry =
      junction['form_schema_entry_id'] as Map<String, dynamic>? ?? junction;
  final key = entry['key'] as String? ?? entry['name'] as String?;
  if (key == null) return null;

  final schema = entry['schema'] as Map<String, dynamic>?;
  final type = CmsFormFieldType.fromFormKit(schema?[r'$formkit'] as String?);
  final translation = _firstTranslation(entry['translations']);
  final validation = entry['validation'] as String?;

  return CmsFormField(
    key: key,
    type: type,
    label: translation?['label'] as String?,
    placeholder: translation?['placeholder'] as String?,
    validation: validation,
    validationLabel: translation?['validation_label'] as String?,
    required: _isRequired(validation),
    multiple: schema?['multiple'] == true,
    // FormKit dropdown options live in `schema.options` as `{text, value}`.
    options: _mapOptions(schema?['options']),
  );
}

bool _isRequired(String? validation) {
  if (validation == null) return false;
  // Tolerate the CMS "requires" typo alongside the correct "required".
  return validation
      .split('|')
      .map((rule) => rule.trim())
      .any((rule) => rule == 'required' || rule == 'requires');
}

List<CmsFormFieldOption> _mapOptions(dynamic options) {
  if (options is! List) return const [];
  final result = <CmsFormFieldOption>[];
  for (final option in options) {
    if (option is Map) {
      final value = (option['value'] ?? option['id'])?.toString();
      final label = (option['text'] ?? option['label'] ?? value)?.toString();
      if (value != null && label != null) {
        result.add(CmsFormFieldOption(value: value, label: label));
      }
    }
  }
  return result;
}

Map<String, dynamic>? _firstTranslation(dynamic translations) {
  if (translations is List && translations.isNotEmpty) {
    final first = translations.first;
    if (first is Map<String, dynamic>) return first;
  }
  return null;
}
