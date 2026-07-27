import 'path_material.dart';

/// Domain entity that represents the detail of a single path area.
class PathAreaDetail {
  const PathAreaDetail({
    required this.area,
    required this.percorsoInternalName,
    required this.completed,
    required this.total,
    required this.timeframeGroups,
    this.groups = const [],
    this.hasMaterials = false,
    this.materialsGroupId,
    this.isLocked = false,
    this.isRestricted = false,
  });

  /// Clean area key (e.g. `allenamento`).
  final String area;

  /// Full percorso identifier as returned by the backend (e.g. `allenamento~tipo-4-m~m`).
  final String percorsoInternalName;

  final int completed;
  final int total;
  final List<PathTimeframeGroup> timeframeGroups;

  /// Content groups of the area (e.g. Benessere's Mindfulness / Self care /
  /// Stili di vita), each with its own completion figure. Only the wellbeing
  /// screen renders these as cards; other areas ignore them.
  final List<PathAreaGroup> groups;

  /// Whether the area exposes a non-progressive "Materiali" group.
  final bool hasMaterials;

  /// Id of the "Materiali" group (`is_percorso_main_tab: false`), used to load
  /// the materials hub. Null when the area has no such group.
  final String? materialsGroupId;

  /// Whether the whole area is locked (`access.percorso_locked`).
  final bool isLocked;

  /// Whether the user has restricted access to this area (`access.restricted`),
  /// i.e. a single-product user who must unlock the full programme with a
  /// starter-kit barcode. Drives the locked card + unlock bottom sheets.
  final bool isRestricted;

  double get progress => total == 0 ? 0 : completed / total;

  /// Completion as an integer percentage (0-100).
  int get percent => (progress * 100).round();

  PathAreaDetail copyWith({List<PathAreaGroup>? groups}) {
    return PathAreaDetail(
      area: area,
      percorsoInternalName: percorsoInternalName,
      completed: completed,
      total: total,
      timeframeGroups: timeframeGroups,
      groups: groups ?? this.groups,
      hasMaterials: hasMaterials,
      materialsGroupId: materialsGroupId,
      isLocked: isLocked,
      isRestricted: isRestricted,
    );
  }
}

/// A content group inside an area (a `percorsi_groups` row), e.g. the three
/// Benessere sub-sections. Carries the group's own `completed/total` figure.
class PathAreaGroup {
  const PathAreaGroup({
    required this.id,
    required this.title,
    required this.completed,
    required this.total,
    this.months = const [],
    this.categories = const [],
  });

  final String id;
  final String title;
  final int completed;
  final int total;

  /// The area's months (timeframes) for this group. Always the full set of
  /// months so the group detail can show every month even when the group has
  /// no steps yet — such months come through locked with a 0/0 count.
  final List<PathTimeframeGroup> months;

  /// The group's official material categories (from `groups[].categories` on
  /// `GET /path/me/areas/{area}/steps`), e.g. Benessere's "Scopri" /
  /// "Consigli utili". Authoritative source for the materials hub's category
  /// tabs — deriving them from the materials list instead let a mistagged
  /// material surface a duplicate-titled tab. See [[statistics-feature-status]].
  final List<PathMaterialCategory> categories;

  double get progress => total == 0 ? 0 : completed / total;

  /// Completion as an integer percentage (0-100).
  int get percent => (progress * 100).round();

  PathAreaGroup copyWith({int? completed, int? total}) {
    return PathAreaGroup(
      id: id,
      title: title,
      completed: completed ?? this.completed,
      total: total ?? this.total,
      months: months,
      categories: categories,
    );
  }
}

/// A group of steps sharing the same timeframe (e.g. "1° mese").
class PathTimeframeGroup {
  const PathTimeframeGroup({
    required this.timeframeId,
    required this.title,
    required this.completed,
    required this.total,
    required this.steps,
    this.isLocked = false,
    this.isCurrent = false,
  });

  final int timeframeId;
  final String title;
  final int completed;
  final int total;
  final List<PathStepItem> steps;

  /// Whether this month is locked (`timeframes[].locked`).
  final bool isLocked;

  /// Whether this is the active month (`timeframes[].is_current`).
  final bool isCurrent;

  double get progress => total == 0 ? 0 : completed / total;

  /// Completion as an integer percentage (0-100).
  int get percent => (progress * 100).round();
}

/// A single step inside an area detail.
class PathStepItem {
  const PathStepItem({
    required this.id,
    required this.title,
    required this.timeframeTitle,
    required this.asset,
    required this.isCompleted,
    required this.isStarted,
    required this.isCurrent,
    required this.isLocked,
    this.description,
  });

  final String id;
  final String title;
  final String timeframeTitle;

  /// Long localized body shown on the step detail screen.
  ///
  /// Not yet exposed by the backend (step `translations` only carry `title`),
  /// so it is currently always `null`; the detail screen renders nothing in
  /// its place until the field is populated.
  final String? description;
  final PathStepMedia asset;
  final bool isCompleted;
  final bool isStarted;
  final bool isCurrent;
  final bool isLocked;
}

/// Media asset for a step: either a Vimeo video or an image.
class PathStepMedia {
  const PathStepMedia({required this.isVideo, this.vimeoUrl, this.imageUrl});

  final bool isVideo;
  final String? vimeoUrl;
  final String? imageUrl;

  /// Returns the embed URL for a Vimeo link, preserving query parameters.
  ///
  /// Input:  `https://vimeo.com/1120185037?ts=0&share=copy`
  /// Output: `https://player.vimeo.com/video/1120185037?ts=0&share=copy`
  String? get vimeoEmbedUrl {
    final url = vimeoUrl;
    if (url == null || url.isEmpty) return null;

    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    final segments = uri.pathSegments;
    if (segments.isEmpty) return null;

    final videoId = segments.first;
    return Uri(
      scheme: 'https',
      host: 'player.vimeo.com',
      pathSegments: ['video', videoId],
      queryParameters: uri.queryParameters.isEmpty ? null : uri.queryParameters,
    ).toString();
  }
}
