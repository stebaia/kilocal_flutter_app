import 'dart:io';

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'gallery_api.g.dart';

/// Retrofit client for the Foto Gallery endpoints under `/tools/photo-gallery`.
///
/// Reads go through GraphQL (`user_photos`) instead — only writes are REST.
/// Contract verified live against staging; see [[photo-gallery-schema]].
@RestApi()
abstract class GalleryApi {
  factory GalleryApi(Dio dio, {String? baseUrl}) = _GalleryApi;

  /// `POST /tools/photo-gallery` — multipart upload of a single image.
  ///
  /// Responds `{"data":{"fileId":"<uuid>","userPhotoId":<int>}}`. The ids are
  /// unused: callers re-fetch the list, which carries the asset metadata.
  @POST('/tools/photo-gallery')
  @MultiPart()
  Future<void> upload(@Part(name: 'file') File file);

  /// `DELETE /tools/photo-gallery` — removes a photo by its **file** id
  /// (`directus_files.id`), not the `user_photos` row id.
  @DELETE('/tools/photo-gallery')
  Future<void> delete(@Body() Map<String, dynamic> body);
}
