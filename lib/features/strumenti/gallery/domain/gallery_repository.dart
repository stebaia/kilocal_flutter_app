import 'dart:io';

import 'entities/gallery_photo.dart';

/// Source of truth for the user's Foto Gallery photos and the tool's CMS copy.
abstract class GalleryRepository {
  /// The user's photos, newest first.
  Future<List<GalleryPhoto>> getPhotos();

  /// The tool's CMS copy and its blocked flag.
  Future<GalleryContent> getContent();

  /// Uploads [file] and returns the refreshed list (the upload response carries
  /// only the new ids, not the row).
  Future<List<GalleryPhoto>> upload(File file);

  /// Deletes [photo] by its file id.
  Future<void> delete(GalleryPhoto photo);
}
