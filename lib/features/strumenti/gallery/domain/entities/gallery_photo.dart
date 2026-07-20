import 'package:equatable/equatable.dart';

/// A photo the user uploaded to the Foto Gallery (`user_photos` row).
class GalleryPhoto extends Equatable {
  const GalleryPhoto({
    required this.id,
    required this.fileId,
    required this.imageUrl,
    this.takenAt,
  });

  /// `user_photos.id`. The backend returns it as an int on upload and a string
  /// over GraphQL, so it is normalized to a string.
  final String id;

  /// `directus_files.id` — the handle the delete endpoint takes.
  final String fileId;

  /// Absolute `/assets/{fileId}` URL.
  final String imageUrl;

  /// `date_created` — when the photo was uploaded.
  final DateTime? takenAt;

  @override
  List<Object?> get props => [id, fileId, imageUrl, takenAt];
}

/// Static copy for the tool, served by the `photo_gallery` CMS singleton.
///
/// Every label in the designs comes from here rather than from ARB, so the
/// wording can change without a release. See [[photo-gallery-schema]].
class GalleryContent extends Equatable {
  const GalleryContent({
    this.title,
    this.photosTitle,
    this.splitViewTitle,
    this.choose2Photos,
    this.chooseOtherPhoto,
    this.choosePhotoComplete,
    this.ctaShowSplit,
    this.uploadModalTitle,
    this.uploadModalInfo,
    this.uploadModalCtaUpload,
    this.uploadModalCtaCancel,
    this.deleteModalTitle,
    this.deleteModalContent,
    this.deleteModalCtaConfirm,
    this.ctaDeleteLabel,
    this.isToolBlocked = false,
  });

  final String? title;
  final String? photosTitle;
  final String? splitViewTitle;

  /// The three states of the selection CTA: nothing picked, one picked, both
  /// picked.
  final String? choose2Photos;
  final String? chooseOtherPhoto;
  final String? choosePhotoComplete;

  final String? ctaShowSplit;

  final String? uploadModalTitle;

  /// HTML.
  final String? uploadModalInfo;
  final String? uploadModalCtaUpload;
  final String? uploadModalCtaCancel;

  final String? deleteModalTitle;

  /// HTML.
  final String? deleteModalContent;
  final String? deleteModalCtaConfirm;
  final String? ctaDeleteLabel;

  /// CMS kill-switch for the whole tool.
  final bool isToolBlocked;

  @override
  List<Object?> get props => [
    title,
    photosTitle,
    splitViewTitle,
    choose2Photos,
    chooseOtherPhoto,
    choosePhotoComplete,
    ctaShowSplit,
    uploadModalTitle,
    uploadModalInfo,
    uploadModalCtaUpload,
    uploadModalCtaCancel,
    deleteModalTitle,
    deleteModalContent,
    deleteModalCtaConfirm,
    ctaDeleteLabel,
    isToolBlocked,
  ];
}
