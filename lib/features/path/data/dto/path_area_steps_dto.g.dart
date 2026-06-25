// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'path_area_steps_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PathAreaStepsResponseDto _$PathAreaStepsResponseDtoFromJson(
  Map<String, dynamic> json,
) => PathAreaStepsResponseDto(
  data: PathAreaStepsDto.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PathAreaStepsResponseDtoToJson(
  PathAreaStepsResponseDto instance,
) => <String, dynamic>{'data': instance.data};

PathAreaStepsDto _$PathAreaStepsDtoFromJson(Map<String, dynamic> json) =>
    PathAreaStepsDto(
      area: json['area'] as String,
      percorso: PathPercorsoDto.fromJson(
        json['percorso'] as Map<String, dynamic>,
      ),
      progress: PathAreaProgressDto.fromJson(
        json['progress'] as Map<String, dynamic>,
      ),
      currentStepId: _nullableIdFromJson(json['current_step_id']),
      activeTimeframe: json['active_timeframe'] == null
          ? null
          : PathActiveTimeframeDto.fromJson(
              json['active_timeframe'] as Map<String, dynamic>,
            ),
      groups: (json['groups'] as List<dynamic>)
          .map((e) => PathGroupDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      access: json['access'] == null
          ? null
          : PathAccessDto.fromJson(json['access'] as Map<String, dynamic>),
      timeframes: (json['timeframes'] as List<dynamic>?)
          ?.map((e) => PathTimeframeDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PathAreaStepsDtoToJson(PathAreaStepsDto instance) =>
    <String, dynamic>{
      'area': instance.area,
      'current_step_id': instance.currentStepId,
      'percorso': instance.percorso,
      'progress': instance.progress,
      'active_timeframe': instance.activeTimeframe,
      'groups': instance.groups,
      'access': instance.access,
      'timeframes': instance.timeframes,
    };

PathPercorsoDto _$PathPercorsoDtoFromJson(Map<String, dynamic> json) =>
    PathPercorsoDto(
      id: _idFromJson(json['id']),
      internalName: json['internal_name'] as String,
      hasProgressiveSteps: json['has_progressive_steps'] as bool,
    );

Map<String, dynamic> _$PathPercorsoDtoToJson(PathPercorsoDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'internal_name': instance.internalName,
      'has_progressive_steps': instance.hasProgressiveSteps,
    };

PathAreaProgressDto _$PathAreaProgressDtoFromJson(Map<String, dynamic> json) =>
    PathAreaProgressDto(
      completed: (json['completed'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      percent: (json['percent'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$PathAreaProgressDtoToJson(
  PathAreaProgressDto instance,
) => <String, dynamic>{
  'completed': instance.completed,
  'total': instance.total,
  'percent': instance.percent,
};

PathActiveTimeframeDto _$PathActiveTimeframeDtoFromJson(
  Map<String, dynamic> json,
) => PathActiveTimeframeDto(
  id: (json['id'] as num).toInt(),
  sort: (json['sort'] as num).toInt(),
);

Map<String, dynamic> _$PathActiveTimeframeDtoToJson(
  PathActiveTimeframeDto instance,
) => <String, dynamic>{'id': instance.id, 'sort': instance.sort};

PathGroupDto _$PathGroupDtoFromJson(Map<String, dynamic> json) => PathGroupDto(
  id: _idFromJson(json['id']),
  sort: (json['sort'] as num).toInt(),
  isPercorsoMainTab: json['is_percorso_main_tab'] as bool,
  showLimitedStepsValue: (json['show_limited_steps_value'] as num?)?.toInt(),
  icon: json['icon'] == null
      ? null
      : DirectusFileDto.fromJson(json['icon'] as Map<String, dynamic>),
  tools: (json['tools'] as List<dynamic>?)?.map((e) => e as String).toList(),
  categories: json['categories'] as List<dynamic>?,
  translations: (json['translations'] as List<dynamic>)
      .map((e) => PathTranslationDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  steps: (json['steps'] as List<dynamic>)
      .map((e) => PathStepDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PathGroupDtoToJson(PathGroupDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sort': instance.sort,
      'is_percorso_main_tab': instance.isPercorsoMainTab,
      'show_limited_steps_value': instance.showLimitedStepsValue,
      'icon': instance.icon,
      'tools': instance.tools,
      'categories': instance.categories,
      'translations': instance.translations,
      'steps': instance.steps,
    };

PathStepDto _$PathStepDtoFromJson(Map<String, dynamic> json) => PathStepDto(
  id: _idFromJson(json['id']),
  sort: (json['sort'] as num).toInt(),
  timeframe: PathTimeframeDto.fromJson(
    json['timeframe'] as Map<String, dynamic>,
  ),
  translations: (json['translations'] as List<dynamic>)
      .map((e) => PathTranslationDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  asset: PathStepAssetDto.fromJson(json['asset'] as Map<String, dynamic>),
  started: json['started'] as bool,
  completed: json['completed'] as bool,
  startedOn: json['started_on'] as String?,
  completedOn: json['completed_on'] as String?,
  isCurrent: json['is_current'] as bool,
  locked: json['locked'] as bool,
);

Map<String, dynamic> _$PathStepDtoToJson(PathStepDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sort': instance.sort,
      'timeframe': instance.timeframe,
      'translations': instance.translations,
      'asset': instance.asset,
      'started_on': instance.startedOn,
      'completed_on': instance.completedOn,
      'started': instance.started,
      'completed': instance.completed,
      'is_current': instance.isCurrent,
      'locked': instance.locked,
    };

PathTimeframeDto _$PathTimeframeDtoFromJson(Map<String, dynamic> json) =>
    PathTimeframeDto(
      id: (json['id'] as num).toInt(),
      sort: (json['sort'] as num).toInt(),
      translations: (json['translations'] as List<dynamic>)
          .map((e) => PathTranslationDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      locked: json['locked'] as bool?,
      isCurrent: json['is_current'] as bool?,
    );

Map<String, dynamic> _$PathTimeframeDtoToJson(PathTimeframeDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sort': instance.sort,
      'translations': instance.translations,
      'locked': instance.locked,
      'is_current': instance.isCurrent,
    };

PathAccessDto _$PathAccessDtoFromJson(Map<String, dynamic> json) =>
    PathAccessDto(percorsoLocked: json['percorso_locked'] as bool? ?? false);

Map<String, dynamic> _$PathAccessDtoToJson(PathAccessDto instance) =>
    <String, dynamic>{'percorso_locked': instance.percorsoLocked};

PathStepAssetDto _$PathStepAssetDtoFromJson(Map<String, dynamic> json) =>
    PathStepAssetDto(
      assetIsVideo: json['asset_is_video'] as bool,
      vimeoUrl: json['vimeo_url'] as String?,
      defaultAsset: json['default_asset'] as String?,
      mobileAsset: json['mobile_asset'] as String?,
      mobileResolution: json['mobile_resolution'] as String?,
      video: json['video'],
      translations: (json['translations'] as List<dynamic>)
          .map((e) => PathTranslationDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PathStepAssetDtoToJson(PathStepAssetDto instance) =>
    <String, dynamic>{
      'asset_is_video': instance.assetIsVideo,
      'vimeo_url': instance.vimeoUrl,
      'default_asset': instance.defaultAsset,
      'mobile_asset': instance.mobileAsset,
      'mobile_resolution': instance.mobileResolution,
      'video': instance.video,
      'translations': instance.translations,
    };

PathTranslationDto _$PathTranslationDtoFromJson(Map<String, dynamic> json) =>
    PathTranslationDto(
      languagesCode: json['languages_code'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$PathTranslationDtoToJson(PathTranslationDto instance) =>
    <String, dynamic>{
      'languages_code': instance.languagesCode,
      'title': instance.title,
      'description': instance.description,
    };

DirectusFileDto _$DirectusFileDtoFromJson(Map<String, dynamic> json) =>
    DirectusFileDto(
      id: json['id'] as String,
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      type: json['type'] as String?,
    );

Map<String, dynamic> _$DirectusFileDtoToJson(DirectusFileDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'width': instance.width,
      'height': instance.height,
      'type': instance.type,
    };
