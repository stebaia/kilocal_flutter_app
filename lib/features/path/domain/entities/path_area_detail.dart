/// Domain entity that represents the detail of a single path area.
class PathAreaDetail {
  const PathAreaDetail({
    required this.area,
    required this.percorsoInternalName,
    required this.completed,
    required this.total,
    required this.timeframeGroups,
    this.hasMaterials = false,
    this.isLocked = false,
  });

  /// Clean area key (e.g. `allenamento`).
  final String area;

  /// Full percorso identifier as returned by the backend (e.g. `allenamento~tipo-4-m~m`).
  final String percorsoInternalName;

  final int completed;
  final int total;
  final List<PathTimeframeGroup> timeframeGroups;

  /// Whether the area exposes a non-progressive "Materiali" group.
  final bool hasMaterials;

  /// Whether the whole area is locked (`access.percorso_locked`).
  final bool isLocked;

  double get progress => total == 0 ? 0 : completed / total;

  /// Completion as an integer percentage (0-100).
  int get percent => (progress * 100).round();
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
  });

  final String id;
  final String title;
  final String timeframeTitle;
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
