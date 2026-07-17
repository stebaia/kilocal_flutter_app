import 'dart:io';

import '../../../../core/config/env.dart';
import '../../../../core/network/graphql_client.dart';
import '../domain/entities/gallery_photo.dart';
import '../domain/gallery_repository.dart';
import 'gallery_api.dart';

/// Photos are read over GraphQL (`user_photos`) and written over REST
/// (`/tools/photo-gallery`); the tool's copy comes from the `photo_gallery`
/// singleton. Shapes verified live; see [[photo-gallery-schema]].
class GalleryRepositoryImpl implements GalleryRepository {
  GalleryRepositoryImpl({
    required GalleryApi api,
    required GraphqlClient graphql,
  }) : _api = api,
       _graphql = graphql;

  final GalleryApi _api;
  final GraphqlClient _graphql;

  static const _photosQuery = r'''
    query UserPhotos {
      user_photos(sort: ["-date_created"]) {
        id
        date_created
        file {
          id
          filename_download
        }
      }
    }
  ''';

  /// `photo_gallery` is a singleton, so it takes no filter. Italian copy only:
  /// the tool ships `it-IT` and the app's default locale is Italian.
  static const _contentQuery = r'''
    query PhotoGalleryContent {
      photo_gallery {
        is_tool_blocked
        translations(filter: { languages_code: { code: { _eq: "it-IT" } } }) {
          title
          sec_photos_title
          split_view_title
          choose_2_photos
          choose_other_photo
          choose_photo_complete
          cta_show_split
          cta_delete_label
          upload_modal_title
          upload_modal_info
          upload_modal_cta_upload
          upload_modal_cta_cancel
          delete_modal_title
          delete_modal_content
          delete_modal_cta_confirm_label
        }
      }
    }
  ''';

  @override
  Future<List<GalleryPhoto>> getPhotos() async {
    final body = await _graphql.query(_photosQuery);
    final data = body['data'] as Map<String, dynamic>?;
    final rows = data?['user_photos'] as List<dynamic>? ?? const [];

    return rows
        .whereType<Map<String, dynamic>>()
        .map(_photoFromRow)
        .whereType<GalleryPhoto>()
        .toList();
  }

  @override
  Future<GalleryContent> getContent() async {
    final body = await _graphql.query(_contentQuery);
    final data = body['data'] as Map<String, dynamic>?;
    final gallery = data?['photo_gallery'] as Map<String, dynamic>?;
    if (gallery == null) return const GalleryContent();

    final translations = gallery['translations'] as List<dynamic>?;
    final t = translations?.whereType<Map<String, dynamic>>().firstOrNull;

    String? str(String key) => t?[key] as String?;

    return GalleryContent(
      // Staging ships the tool blocked, so debug builds ignore the flag to keep
      // it testable; release always honours the CMS. See [Env.ignoreToolBlocked].
      isToolBlocked: Env.ignoreToolBlocked
          ? false
          : gallery['is_tool_blocked'] as bool? ?? false,
      title: str('title'),
      photosTitle: str('sec_photos_title'),
      splitViewTitle: str('split_view_title'),
      choose2Photos: str('choose_2_photos'),
      chooseOtherPhoto: str('choose_other_photo'),
      choosePhotoComplete: str('choose_photo_complete'),
      ctaShowSplit: str('cta_show_split'),
      ctaDeleteLabel: str('cta_delete_label'),
      uploadModalTitle: str('upload_modal_title'),
      uploadModalInfo: str('upload_modal_info'),
      uploadModalCtaUpload: str('upload_modal_cta_upload'),
      uploadModalCtaCancel: str('upload_modal_cta_cancel'),
      deleteModalTitle: str('delete_modal_title'),
      deleteModalContent: str('delete_modal_content'),
      deleteModalCtaConfirm: str('delete_modal_cta_confirm_label'),
    );
  }

  @override
  Future<List<GalleryPhoto>> upload(File file) async {
    await _api.upload(file);
    return getPhotos();
  }

  @override
  Future<void> delete(GalleryPhoto photo) =>
      _api.delete({'fileId': photo.fileId});

  /// Rows whose `file` is missing are skipped: without a file id there is
  /// nothing to render or delete.
  GalleryPhoto? _photoFromRow(Map<String, dynamic> row) {
    final file = row['file'] as Map<String, dynamic>?;
    final fileId = file?['id'] as String?;
    if (fileId == null) return null;

    final created = row['date_created'] as String?;

    return GalleryPhoto(
      id: row['id']?.toString() ?? '',
      fileId: fileId,
      imageUrl: '${Env.baseUrl}/assets/$fileId',
      takenAt: created == null ? null : DateTime.tryParse(created)?.toLocal(),
    );
  }
}
