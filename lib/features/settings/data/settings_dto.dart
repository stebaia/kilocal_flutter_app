import 'package:json_annotation/json_annotation.dart';

part 'settings_dto.g.dart';

/// Response of `GET /api/settings` (`wiki/settings.md`).
///
/// Shape: `{ "settings": { main_menu, footer_menu, generic_strings } }`. On error
/// the backend returns `{ "settings": {} }` with no error status
/// (see `wiki/contradictions.md` §5), so [settings] may legitimately be empty.
@JsonSerializable()
class SettingsDto {
  const SettingsDto({this.settings = const {}});

  final Map<String, dynamic> settings;

  factory SettingsDto.fromJson(Map<String, dynamic> json) =>
      _$SettingsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsDtoToJson(this);
}
