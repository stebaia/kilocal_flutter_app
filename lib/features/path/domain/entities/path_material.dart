import 'package:equatable/equatable.dart';

/// A single "Materiali extra" card in the materials hub.
///
/// Backed by the `percorsi_materials` collection. The leading card icon (play
/// vs document) is driven by [isVideo]; [isAvailable] maps to the published
/// status shown as the "Disponibile" badge.
class PathMaterial extends Equatable {
  const PathMaterial({
    required this.id,
    required this.title,
    required this.isVideo,
    required this.isAvailable,
    required this.isCompleted,
    required this.categoryIds,
    this.imageUrl,
    this.hidesImage = false,
  });

  final String id;
  final String title;

  /// Whether the material's asset is a video (`asset.asset_is_video`).
  final bool isVideo;

  /// Whether the material is published/available ("Disponibile" badge).
  final bool isAvailable;

  /// Whether the user has completed this material (a `user_activities` row on
  /// collection `percorsi_materials` with `completed_on` set). Drives the
  /// "Completati" filter.
  final bool isCompleted;

  /// Ids of the categories this material belongs to; used to filter by tab.
  final List<String> categoryIds;

  /// Hero image (default/mobile asset). Null when the material has no asset
  /// (e.g. it links to an article instead).
  final String? imageUrl;

  /// Whether the card must be rendered without its cover image: the editorial
  /// "Consigli utili" and the "Schede" are text-only by design. "Ricette" keep
  /// their cover (the linked article's hero).
  final bool hidesImage;

  @override
  List<Object?> get props => [
    id,
    title,
    isVideo,
    isAvailable,
    isCompleted,
    categoryIds,
    imageUrl,
    hidesImage,
  ];
}

/// Full detail of a single material, used by the material detail screen.
///
/// A material is either a **video** (Vimeo player, reusing the path-step video
/// layout) or a **text/image** material (hero image + title + HTML body).
///
/// Materials flagged `connect_to_article` carry no body of their own: [content]
/// is then composed from the linked article's `plot` and its `block_text`
/// blocks, and [subtitle]/[imageUrl] likewise fall back to the article.
class PathMaterialDetail extends Equatable {
  const PathMaterialDetail({
    required this.id,
    required this.title,
    required this.isVideo,
    this.isCompleted = false,
    this.subtitle,
    this.content,
    this.imageUrl,
    this.vimeoUrl,
    this.attachments = const [],
    this.hidesImage = false,
  });

  final String id;
  final String title;

  /// Whether the material is a video (`asset.asset_is_video`).
  final bool isVideo;

  /// Whether the user has already marked this material as completed
  /// ("Segna come completato"). Drives whether the CTA shows and its state.
  final bool isCompleted;

  /// Optional subtitle shown under the title; only linked articles carry one,
  /// and rarely.
  final String? subtitle;

  /// HTML body shown under the title for text materials.
  final String? content;

  /// Hero image (default asset) for text/image materials, or the video poster.
  final String? imageUrl;

  /// Vimeo url for video materials (`asset.vimeo_url`).
  final String? vimeoUrl;

  /// Downloadable files offered by the material's CTAs — the PDFs of the
  /// "Schede" materials. Empty for materials that offer no download.
  final List<PathMaterialAttachment> attachments;

  /// Whether the detail must be rendered without its hero image: the editorial
  /// "Consigli utili" are text-only by design.
  final bool hidesImage;

  /// Embed url for the Vimeo player, preserving query parameters.
  String? get vimeoEmbedUrl {
    final url = vimeoUrl;
    if (url == null || url.isEmpty) return null;

    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    final segments = uri.pathSegments;
    if (segments.isEmpty) return null;

    return Uri(
      scheme: 'https',
      host: 'player.vimeo.com',
      pathSegments: ['video', segments.first],
      queryParameters: uri.queryParameters.isEmpty ? null : uri.queryParameters,
    ).toString();
  }

  PathMaterialDetail copyWith({bool? isCompleted}) {
    return PathMaterialDetail(
      id: id,
      title: title,
      isVideo: isVideo,
      isCompleted: isCompleted ?? this.isCompleted,
      subtitle: subtitle,
      content: content,
      imageUrl: imageUrl,
      vimeoUrl: vimeoUrl,
      attachments: attachments,
      hidesImage: hidesImage,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    isVideo,
    isCompleted,
    subtitle,
    content,
    imageUrl,
    vimeoUrl,
    attachments,
    hidesImage,
  ];
}

/// A downloadable file attached to a material through a CTA (`links` row with
/// a per-language `attachment`), e.g. the PDF of a "Scheda".
class PathMaterialAttachment extends Equatable {
  const PathMaterialAttachment({required this.url, required this.label});

  /// Direct `/assets` url of the file; served without authentication.
  final String url;

  /// CTA text from the CMS ("Scarica il file"), falling back to the file name.
  final String label;

  @override
  List<Object?> get props => [url, label];
}

/// A category tab shown at the top of the materials hub
/// (`percorsi_material_categories`).
class PathMaterialCategory extends Equatable {
  const PathMaterialCategory({
    required this.id,
    required this.title,
    this.internalName,
  });

  final String id;
  final String title;

  /// Stable CMS slug (`internal_name`), e.g. `consigli-utili`. Unlike [title] it
  /// is not translated, so it is what feature checks key off.
  final String? internalName;

  /// Whether this category's cards are listed without a cover image.
  ///
  /// "Ricette" deliberately do NOT belong here: they show the linked article's
  /// hero, both in the list and in the detail.
  bool get hidesImage =>
      internalName != null &&
      PathMaterialCategories.imageless.contains(internalName);

  @override
  List<Object?> get props => [id, title, internalName];
}

/// Known `percorsi_material_categories.internal_name` values the app keys off.
abstract final class PathMaterialCategories {
  /// "Consigli utili" — its materials are rendered text-only, with no image in
  /// the list card nor in the detail.
  static const advice = 'consigli-utili';

  /// "Schede" — downloadable PDFs, listed without a cover image.
  static const sheets = 'schede';

  /// Categories whose cards carry no cover image in the list.
  static const imageless = {advice, sheets};
}

/// The full materials hub payload for one area: the available category tabs and
/// the materials, already mapped from the `percorsi_materials` collection.
class PathMaterialsData extends Equatable {
  const PathMaterialsData({required this.categories, required this.materials});

  final List<PathMaterialCategory> categories;
  final List<PathMaterial> materials;

  @override
  List<Object?> get props => [categories, materials];
}
