// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'path_material_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PathMaterialJunctionDto _$PathMaterialJunctionDtoFromJson(
  Map<String, dynamic> json,
) => PathMaterialJunctionDto(
  material: json['percorsi_materials_id'] == null
      ? null
      : PathMaterialDto.fromJson(
          json['percorsi_materials_id'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$PathMaterialJunctionDtoToJson(
  PathMaterialJunctionDto instance,
) => <String, dynamic>{'percorsi_materials_id': instance.material};

PathMaterialDto _$PathMaterialDtoFromJson(
  Map<String, dynamic> json,
) => PathMaterialDto(
  id: _idFromJson(json['id']),
  status: json['status'] as String?,
  connectToArticle: json['connect_to_article'] as bool? ?? false,
  asset: json['asset'] == null
      ? null
      : PathMaterialAssetDto.fromJson(json['asset'] as Map<String, dynamic>),
  translations:
      (json['translations'] as List<dynamic>?)
          ?.map(
            (e) =>
                PathMaterialTranslationDto.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  categories:
      (json['categories'] as List<dynamic>?)
          ?.map(
            (e) => PathMaterialCategoryJunctionDto.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList() ??
      const [],
);

Map<String, dynamic> _$PathMaterialDtoToJson(PathMaterialDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'connect_to_article': instance.connectToArticle,
      'asset': instance.asset,
      'translations': instance.translations,
      'categories': instance.categories,
    };

PathMaterialTranslationDto _$PathMaterialTranslationDtoFromJson(
  Map<String, dynamic> json,
) => PathMaterialTranslationDto(
  title: json['title'] as String?,
  content: json['content'] as String?,
  languagesCode: json['languages_code'] == null
      ? null
      : PathMaterialLanguageDto.fromJson(
          json['languages_code'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$PathMaterialTranslationDtoToJson(
  PathMaterialTranslationDto instance,
) => <String, dynamic>{
  'title': instance.title,
  'content': instance.content,
  'languages_code': instance.languagesCode,
};

PathMaterialLanguageDto _$PathMaterialLanguageDtoFromJson(
  Map<String, dynamic> json,
) => PathMaterialLanguageDto(code: json['code'] as String?);

Map<String, dynamic> _$PathMaterialLanguageDtoToJson(
  PathMaterialLanguageDto instance,
) => <String, dynamic>{'code': instance.code};

PathMaterialAssetDto _$PathMaterialAssetDtoFromJson(
  Map<String, dynamic> json,
) => PathMaterialAssetDto(
  assetIsVideo: json['asset_is_video'] as bool? ?? false,
  vimeoUrl: json['vimeo_url'] as String?,
  defaultAsset: json['default_asset'] == null
      ? null
      : PathMaterialFileDto.fromJson(
          json['default_asset'] as Map<String, dynamic>,
        ),
  mobileAsset: json['mobile_asset'] == null
      ? null
      : PathMaterialFileDto.fromJson(
          json['mobile_asset'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$PathMaterialAssetDtoToJson(
  PathMaterialAssetDto instance,
) => <String, dynamic>{
  'asset_is_video': instance.assetIsVideo,
  'vimeo_url': instance.vimeoUrl,
  'default_asset': instance.defaultAsset,
  'mobile_asset': instance.mobileAsset,
};

PathMaterialFileDto _$PathMaterialFileDtoFromJson(Map<String, dynamic> json) =>
    PathMaterialFileDto(
      id: _nullableIdFromJson(json['id']),
      filenameDownload: json['filename_download'] as String?,
    );

Map<String, dynamic> _$PathMaterialFileDtoToJson(
  PathMaterialFileDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'filename_download': instance.filenameDownload,
};

PathMaterialCategoryJunctionDto _$PathMaterialCategoryJunctionDtoFromJson(
  Map<String, dynamic> json,
) => PathMaterialCategoryJunctionDto(
  category: json['percorsi_material_categories_id'] == null
      ? null
      : PathMaterialCategoryDto.fromJson(
          json['percorsi_material_categories_id'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$PathMaterialCategoryJunctionDtoToJson(
  PathMaterialCategoryJunctionDto instance,
) => <String, dynamic>{'percorsi_material_categories_id': instance.category};

PathMaterialCategoryDto _$PathMaterialCategoryDtoFromJson(
  Map<String, dynamic> json,
) => PathMaterialCategoryDto(
  id: _idFromJson(json['id']),
  internalName: json['internal_name'] as String?,
  heroAsset: json['hero_asset'] == null
      ? null
      : PathMaterialHeroAssetDto.fromJson(
          json['hero_asset'] as Map<String, dynamic>,
        ),
  translations:
      (json['translations'] as List<dynamic>?)
          ?.map(
            (e) =>
                PathMaterialTranslationDto.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
);

Map<String, dynamic> _$PathMaterialCategoryDtoToJson(
  PathMaterialCategoryDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'internal_name': instance.internalName,
  'hero_asset': instance.heroAsset,
  'translations': instance.translations,
};

PathMaterialHeroAssetDto _$PathMaterialHeroAssetDtoFromJson(
  Map<String, dynamic> json,
) => PathMaterialHeroAssetDto(
  defaultAsset: json['default_asset'] == null
      ? null
      : PathMaterialFileDto.fromJson(
          json['default_asset'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$PathMaterialHeroAssetDtoToJson(
  PathMaterialHeroAssetDto instance,
) => <String, dynamic>{'default_asset': instance.defaultAsset};
