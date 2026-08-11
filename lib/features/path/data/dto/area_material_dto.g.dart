// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'area_material_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AreaMaterialsDto _$AreaMaterialsDtoFromJson(Map<String, dynamic> json) =>
    AreaMaterialsDto(
      area: json['area'] as String?,
      groupId: _nullableIdFromJson(json['group_id']),
      categoryId: _nullableIdFromJson(json['category_id']),
      materials:
          (json['materials'] as List<dynamic>?)
              ?.map((e) => AreaMaterialDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$AreaMaterialsDtoToJson(AreaMaterialsDto instance) =>
    <String, dynamic>{
      'area': instance.area,
      'group_id': instance.groupId,
      'category_id': instance.categoryId,
      'materials': instance.materials,
    };

AreaMaterialDto _$AreaMaterialDtoFromJson(
  Map<String, dynamic> json,
) => AreaMaterialDto(
  id: _idFromJson(json['id']),
  status: json['status'] as String?,
  sort: (json['sort'] as num?)?.toInt(),
  canCheckAsCompleted: json['can_check_as_completed'] as bool?,
  contentSource: json['content_source'] as String?,
  articleId: _nullableIdFromJson(json['article_id']),
  articleStatus: json['article_status'] as String?,
  articleSlug: json['article_slug'] as String?,
  translations:
      (json['translations'] as List<dynamic>?)
          ?.map(
            (e) =>
                AreaMaterialTranslationDto.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  image: json['image'] == null
      ? null
      : PathMaterialAssetDto.fromJson(json['image'] as Map<String, dynamic>),
  thumbnailUrl: json['thumbnail_url'] as String?,
  categories:
      (json['categories'] as List<dynamic>?)
          ?.map(
            (e) => AreaMaterialCategoryDto.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  completed: json['completed'] as bool? ?? false,
  completedOn: json['completed_on'] as String?,
);

Map<String, dynamic> _$AreaMaterialDtoToJson(AreaMaterialDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'sort': instance.sort,
      'can_check_as_completed': instance.canCheckAsCompleted,
      'content_source': instance.contentSource,
      'article_id': instance.articleId,
      'article_status': instance.articleStatus,
      'article_slug': instance.articleSlug,
      'translations': instance.translations,
      'image': instance.image,
      'thumbnail_url': instance.thumbnailUrl,
      'categories': instance.categories,
      'completed': instance.completed,
      'completed_on': instance.completedOn,
    };

AreaMaterialTranslationDto _$AreaMaterialTranslationDtoFromJson(
  Map<String, dynamic> json,
) => AreaMaterialTranslationDto(
  languagesCode: json['languages_code'] as String?,
  title: json['title'] as String?,
  excerpt: json['excerpt'] as String?,
);

Map<String, dynamic> _$AreaMaterialTranslationDtoToJson(
  AreaMaterialTranslationDto instance,
) => <String, dynamic>{
  'languages_code': instance.languagesCode,
  'title': instance.title,
  'excerpt': instance.excerpt,
};

AreaMaterialCategoryDto _$AreaMaterialCategoryDtoFromJson(
  Map<String, dynamic> json,
) => AreaMaterialCategoryDto(
  id: _nullableIdFromJson(json['id']),
  internalName: json['internal_name'] as String?,
  title: json['title'] as String?,
  translations:
      (json['translations'] as List<dynamic>?)
          ?.map(
            (e) =>
                AreaMaterialTranslationDto.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
);

Map<String, dynamic> _$AreaMaterialCategoryDtoToJson(
  AreaMaterialCategoryDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'internal_name': instance.internalName,
  'title': instance.title,
  'translations': instance.translations,
};
