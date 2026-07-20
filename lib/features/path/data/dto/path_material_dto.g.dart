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
  article: json['article'] == null
      ? null
      : PathMaterialArticleDto.fromJson(
          json['article'] as Map<String, dynamic>,
        ),
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
  ctas:
      (json['ctas'] as List<dynamic>?)
          ?.map(
            (e) =>
                PathMaterialCtaJunctionDto.fromJson(e as Map<String, dynamic>),
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
      'article': instance.article,
      'translations': instance.translations,
      'categories': instance.categories,
      'ctas': instance.ctas,
    };

PathMaterialCtaJunctionDto _$PathMaterialCtaJunctionDtoFromJson(
  Map<String, dynamic> json,
) => PathMaterialCtaJunctionDto(
  link: json['links_id'] == null
      ? null
      : PathMaterialLinkDto.fromJson(json['links_id'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PathMaterialCtaJunctionDtoToJson(
  PathMaterialCtaJunctionDto instance,
) => <String, dynamic>{'links_id': instance.link};

PathMaterialLinkDto _$PathMaterialLinkDtoFromJson(Map<String, dynamic> json) =>
    PathMaterialLinkDto(
      downloadOnClick: json['download_on_click'] as bool? ?? false,
      translations:
          (json['translations'] as List<dynamic>?)
              ?.map(
                (e) => PathMaterialLinkTranslationDto.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const [],
      attachmentTranslations:
          (json['attachemnt_translations'] as List<dynamic>?)
              ?.map(
                (e) => PathMaterialAttachmentTranslationDto.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$PathMaterialLinkDtoToJson(
  PathMaterialLinkDto instance,
) => <String, dynamic>{
  'download_on_click': instance.downloadOnClick,
  'translations': instance.translations,
  'attachemnt_translations': instance.attachmentTranslations,
};

PathMaterialLinkTranslationDto _$PathMaterialLinkTranslationDtoFromJson(
  Map<String, dynamic> json,
) => PathMaterialLinkTranslationDto(
  label: json['label'] as String?,
  url: json['url'] as String?,
);

Map<String, dynamic> _$PathMaterialLinkTranslationDtoToJson(
  PathMaterialLinkTranslationDto instance,
) => <String, dynamic>{'label': instance.label, 'url': instance.url};

PathMaterialAttachmentTranslationDto
_$PathMaterialAttachmentTranslationDtoFromJson(Map<String, dynamic> json) =>
    PathMaterialAttachmentTranslationDto(
      attachment: json['attachment'] == null
          ? null
          : PathMaterialFileDto.fromJson(
              json['attachment'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$PathMaterialAttachmentTranslationDtoToJson(
  PathMaterialAttachmentTranslationDto instance,
) => <String, dynamic>{'attachment': instance.attachment};

PathMaterialArticleDto _$PathMaterialArticleDtoFromJson(
  Map<String, dynamic> json,
) => PathMaterialArticleDto(
  cover: json['cover'] == null
      ? null
      : PathMaterialAssetDto.fromJson(json['cover'] as Map<String, dynamic>),
  translations:
      (json['translations'] as List<dynamic>?)
          ?.map(
            (e) => PathMaterialArticleTranslationDto.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList() ??
      const [],
  blocks:
      (json['blocks'] as List<dynamic>?)
          ?.map((e) => PathMaterialBlockDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$PathMaterialArticleDtoToJson(
  PathMaterialArticleDto instance,
) => <String, dynamic>{
  'cover': instance.cover,
  'translations': instance.translations,
  'blocks': instance.blocks,
};

PathMaterialArticleTranslationDto _$PathMaterialArticleTranslationDtoFromJson(
  Map<String, dynamic> json,
) => PathMaterialArticleTranslationDto(
  title: json['title'] as String?,
  subtitle: json['subtitle'] as String?,
  plot: json['plot'] as String?,
);

Map<String, dynamic> _$PathMaterialArticleTranslationDtoToJson(
  PathMaterialArticleTranslationDto instance,
) => <String, dynamic>{
  'title': instance.title,
  'subtitle': instance.subtitle,
  'plot': instance.plot,
};

PathMaterialBlockDto _$PathMaterialBlockDtoFromJson(
  Map<String, dynamic> json,
) => PathMaterialBlockDto(
  collection: json['collection'] as String?,
  item: json['item'] == null
      ? null
      : PathMaterialBlockItemDto.fromJson(json['item'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PathMaterialBlockDtoToJson(
  PathMaterialBlockDto instance,
) => <String, dynamic>{
  'collection': instance.collection,
  'item': instance.item,
};

PathMaterialBlockItemDto _$PathMaterialBlockItemDtoFromJson(
  Map<String, dynamic> json,
) => PathMaterialBlockItemDto(
  translations:
      (json['translations'] as List<dynamic>?)
          ?.map(
            (e) =>
                PathMaterialTranslationDto.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
);

Map<String, dynamic> _$PathMaterialBlockItemDtoToJson(
  PathMaterialBlockItemDto instance,
) => <String, dynamic>{'translations': instance.translations};

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
