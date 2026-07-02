import 'package:json_annotation/json_annotation.dart';

part 'path_area_steps_dto.g.dart';

/// The backend is inconsistent about id types: some areas return ids as
/// strings (`"42"`), others as integers (`42`). Normalize everything to a
/// string so the DTOs don't crash on `Null is not a subtype of String`.
String _idFromJson(Object? value) => value?.toString() ?? '';

/// Nullable variant for optional ids (e.g. `current_step_id`).
String? _nullableIdFromJson(Object? value) => value?.toString();

/// Response of `GET /path/me/areas/{area}/steps`.
///
/// The backend returns the full area detail: percorso metadata, groups and
/// steps with their completion state. The UI groups steps by timeframe rather
/// than by group.
@JsonSerializable()
class PathAreaStepsResponseDto {
  const PathAreaStepsResponseDto({required this.data});

  factory PathAreaStepsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$PathAreaStepsResponseDtoFromJson(json);

  final PathAreaStepsDto data;

  Map<String, dynamic> toJson() => _$PathAreaStepsResponseDtoToJson(this);
}

@JsonSerializable()
class PathAreaStepsDto {
  const PathAreaStepsDto({
    required this.area,
    required this.percorso,
    required this.progress,
    this.currentStepId,
    this.activeTimeframe,
    required this.groups,
    this.access,
    this.timeframes,
  });

  factory PathAreaStepsDto.fromJson(Map<String, dynamic> json) =>
      _$PathAreaStepsDtoFromJson(json);

  final String area;

  /// Id of the current step, or `null` when the area has no active step
  /// (e.g. a non-progressive area, or progress not started).
  @JsonKey(name: 'current_step_id', fromJson: _nullableIdFromJson)
  final String? currentStepId;

  final PathPercorsoDto percorso;
  final PathAreaProgressDto progress;

  /// Active timeframe pointer; nullable when the area exposes none.
  @JsonKey(name: 'active_timeframe')
  final PathActiveTimeframeDto? activeTimeframe;

  final List<PathGroupDto> groups;

  /// Area-level access flags. Nullable: not present in the older shape, the
  /// backend confirmed it exposes `access.percorso_locked` (whole area locked).
  final PathAccessDto? access;

  /// Top-level per-timeframe (month) state. Nullable: in the older shape the
  /// timeframe was only nested inside each step. The backend confirmed
  /// `timeframes[].locked` / `timeframes[].is_current` as the authoritative
  /// month lock/active flags; when present we read lock state from here.
  final List<PathTimeframeDto>? timeframes;

  Map<String, dynamic> toJson() => _$PathAreaStepsDtoToJson(this);
}

@JsonSerializable()
class PathPercorsoDto {
  const PathPercorsoDto({
    required this.id,
    required this.internalName,
    required this.hasProgressiveSteps,
  });

  factory PathPercorsoDto.fromJson(Map<String, dynamic> json) =>
      _$PathPercorsoDtoFromJson(json);

  @JsonKey(fromJson: _idFromJson)
  final String id;

  @JsonKey(name: 'internal_name')
  final String internalName;

  @JsonKey(name: 'has_progressive_steps')
  final bool hasProgressiveSteps;

  Map<String, dynamic> toJson() => _$PathPercorsoDtoToJson(this);
}

@JsonSerializable()
class PathAreaProgressDto {
  const PathAreaProgressDto({
    this.completed = 0,
    this.total = 0,
    this.percent = 0,
  });

  factory PathAreaProgressDto.fromJson(Map<String, dynamic> json) =>
      _$PathAreaProgressDtoFromJson(json);

  final int completed;
  final int total;
  final int percent;

  Map<String, dynamic> toJson() => _$PathAreaProgressDtoToJson(this);
}

@JsonSerializable()
class PathActiveTimeframeDto {
  const PathActiveTimeframeDto({required this.id, required this.sort});

  factory PathActiveTimeframeDto.fromJson(Map<String, dynamic> json) =>
      _$PathActiveTimeframeDtoFromJson(json);

  final int id;
  final int sort;

  Map<String, dynamic> toJson() => _$PathActiveTimeframeDtoToJson(this);
}

@JsonSerializable()
class PathGroupDto {
  const PathGroupDto({
    required this.id,
    this.sort,
    required this.isPercorsoMainTab,
    this.showLimitedStepsValue,
    this.icon,
    this.tools,
    this.categories,
    required this.translations,
    required this.steps,
  });

  factory PathGroupDto.fromJson(Map<String, dynamic> json) =>
      _$PathGroupDtoFromJson(json);

  @JsonKey(fromJson: _idFromJson)
  final String id;

  /// Group ordering hint. Nullable: the backend sends `sort: null` for groups
  /// (unlike steps/timeframes). Never read by the app — groups are picked by
  /// `is_percorso_main_tab`, not sorted — but a non-null cast here crashed the
  /// whole area parse.
  final int? sort;

  @JsonKey(name: 'is_percorso_main_tab')
  final bool isPercorsoMainTab;

  // Nullable: the "Materiali" group (is_percorso_main_tab=false) omits these.
  @JsonKey(name: 'show_limited_steps_value')
  final int? showLimitedStepsValue;

  final DirectusFileDto? icon;
  final List<String>? tools;
  final List<dynamic>? categories;
  final List<PathTranslationDto> translations;
  final List<PathStepDto> steps;

  Map<String, dynamic> toJson() => _$PathGroupDtoToJson(this);
}

@JsonSerializable()
class PathStepDto {
  const PathStepDto({
    required this.id,
    required this.sort,
    required this.timeframe,
    required this.translations,
    required this.asset,
    required this.started,
    required this.completed,
    this.startedOn,
    this.completedOn,
    required this.isCurrent,
    required this.locked,
  });

  factory PathStepDto.fromJson(Map<String, dynamic> json) =>
      _$PathStepDtoFromJson(json);

  @JsonKey(fromJson: _idFromJson)
  final String id;
  final int sort;
  final PathTimeframeDto timeframe;
  final List<PathTranslationDto> translations;
  final PathStepAssetDto asset;

  @JsonKey(name: 'started_on')
  final String? startedOn;

  @JsonKey(name: 'completed_on')
  final String? completedOn;

  final bool started;
  final bool completed;

  @JsonKey(name: 'is_current')
  final bool isCurrent;

  final bool locked;

  Map<String, dynamic> toJson() => _$PathStepDtoToJson(this);
}

@JsonSerializable()
class PathTimeframeDto {
  const PathTimeframeDto({
    required this.id,
    required this.sort,
    required this.translations,
    this.locked,
    this.isCurrent,
  });

  factory PathTimeframeDto.fromJson(Map<String, dynamic> json) =>
      _$PathTimeframeDtoFromJson(json);

  final int id;
  final int sort;
  final List<PathTranslationDto> translations;

  /// Month lock flag (`timeframes[].locked`). Nullable when absent (older
  /// shape, or when the timeframe is read from the nested step object).
  final bool? locked;

  /// Active month flag (`timeframes[].is_current`). Nullable when absent.
  @JsonKey(name: 'is_current')
  final bool? isCurrent;

  Map<String, dynamic> toJson() => _$PathTimeframeDtoToJson(this);
}

/// Area-level access flags returned under the top-level `access` key.
@JsonSerializable()
class PathAccessDto {
  const PathAccessDto({this.percorsoLocked = false});

  factory PathAccessDto.fromJson(Map<String, dynamic> json) =>
      _$PathAccessDtoFromJson(json);

  /// Whether the whole area is locked (`access.percorso_locked`).
  @JsonKey(name: 'percorso_locked')
  final bool percorsoLocked;

  Map<String, dynamic> toJson() => _$PathAccessDtoToJson(this);
}

@JsonSerializable()
class PathStepAssetDto {
  const PathStepAssetDto({
    required this.assetIsVideo,
    this.vimeoUrl,
    this.defaultAsset,
    this.mobileAsset,
    this.mobileResolution,
    this.video,
    required this.translations,
  });

  factory PathStepAssetDto.fromJson(Map<String, dynamic> json) =>
      _$PathStepAssetDtoFromJson(json);

  @JsonKey(name: 'asset_is_video')
  final bool assetIsVideo;

  @JsonKey(name: 'vimeo_url')
  final String? vimeoUrl;

  @JsonKey(name: 'default_asset')
  final String? defaultAsset;

  @JsonKey(name: 'mobile_asset')
  final String? mobileAsset;

  @JsonKey(name: 'mobile_resolution')
  final String? mobileResolution;

  final dynamic video;
  final List<PathTranslationDto> translations;

  Map<String, dynamic> toJson() => _$PathStepAssetDtoToJson(this);
}

@JsonSerializable()
class PathTranslationDto {
  const PathTranslationDto({
    required this.languagesCode,
    this.title,
    this.description,
  });

  factory PathTranslationDto.fromJson(Map<String, dynamic> json) =>
      _$PathTranslationDtoFromJson(json);

  @JsonKey(name: 'languages_code')
  final String languagesCode;

  /// Localized title. Nullable because some translation rows (e.g. on an
  /// asset) carry only other fields like `alt_text` and omit `title`.
  final String? title;

  /// Long localized body for a step. Exposed by the backend under the
  /// `content` key (HTML markup); nullable until populated. Kept as
  /// `description` internally for the rest of the layers.
  @JsonKey(name: 'content')
  final String? description;

  Map<String, dynamic> toJson() => _$PathTranslationDtoToJson(this);
}

@JsonSerializable()
class DirectusFileDto {
  const DirectusFileDto({required this.id, this.width, this.height, this.type});

  factory DirectusFileDto.fromJson(Map<String, dynamic> json) =>
      _$DirectusFileDtoFromJson(json);

  final String id;
  final int? width;
  final int? height;
  final String? type;

  Map<String, dynamic> toJson() => _$DirectusFileDtoToJson(this);
}

extension PathTranslationDtoExtension on List<PathTranslationDto> {
  /// Returns the first translation that matches the language code, or the first
  /// available translation as a fallback.
  String? titleFor(String languageCode) {
    if (isEmpty) return null;
    return _matchFor(languageCode).title;
  }

  /// Returns the long body for the matching language, or `null` when the
  /// backend has not populated it yet.
  String? descriptionFor(String languageCode) {
    if (isEmpty) return null;
    return _matchFor(languageCode).description;
  }

  PathTranslationDto _matchFor(String languageCode) => firstWhere(
    (t) => t.languagesCode.toLowerCase().startsWith(languageCode.toLowerCase()),
    orElse: () => first,
  );
}
