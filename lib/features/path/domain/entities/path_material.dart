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

  @override
  List<Object?> get props => [
    id,
    title,
    isVideo,
    isAvailable,
    isCompleted,
    categoryIds,
    imageUrl,
  ];
}

/// Full detail of a single material, used by the material detail screen.
///
/// A material is either a **video** (Vimeo player, reusing the path-step video
/// layout) or a **text/image** material (hero image + title + HTML body).
class PathMaterialDetail extends Equatable {
  const PathMaterialDetail({
    required this.id,
    required this.title,
    required this.isVideo,
    this.content,
    this.imageUrl,
    this.vimeoUrl,
  });

  final String id;
  final String title;

  /// Whether the material is a video (`asset.asset_is_video`).
  final bool isVideo;

  /// HTML body shown under the title for text materials.
  final String? content;

  /// Hero image (default asset) for text/image materials, or the video poster.
  final String? imageUrl;

  /// Vimeo url for video materials (`asset.vimeo_url`).
  final String? vimeoUrl;

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

  @override
  List<Object?> get props => [id, title, isVideo, content, imageUrl, vimeoUrl];
}

/// A category tab shown at the top of the materials hub
/// (`percorsi_material_categories`).
class PathMaterialCategory extends Equatable {
  const PathMaterialCategory({required this.id, required this.title});

  final String id;
  final String title;

  @override
  List<Object?> get props => [id, title];
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
