/// Domain entity that represents all data shown on the path screen.
class PathData {
  const PathData({
    required this.overallCompleted,
    required this.overallTotal,
    required this.headerAssetName,
    required this.areas,
  });

  final int overallCompleted;
  final int overallTotal;
  final String headerAssetName;
  final List<PathArea> areas;

  double get overallProgress =>
      overallTotal == 0 ? 0 : overallCompleted / overallTotal;

  PathData copyWith({List<PathArea>? areas}) {
    return PathData(
      overallCompleted: overallCompleted,
      overallTotal: overallTotal,
      headerAssetName: headerAssetName,
      areas: areas ?? this.areas,
    );
  }
}

/// A single area inside the user path (e.g. training, nutrition, wellbeing).
class PathArea {
  const PathArea({
    required this.id,
    required this.title,
    required this.assetName,
    required this.completed,
    required this.total,
    this.isRestricted = false,
  });

  final String id;
  final String title;
  final String assetName;
  final int completed;
  final int total;

  /// Whether the area is locked for a restricted (single-product) user and must
  /// show the unlock flow instead of opening. Derived from `profile_status`
  /// (the progress endpoint carries no per-area restriction flag); the
  /// authoritative per-area truth is `access.restricted` on the area detail.
  final bool isRestricted;

  double get progress => total == 0 ? 0 : completed / total;

  PathArea copyWith({int? completed, int? total, bool? isRestricted}) {
    return PathArea(
      id: id,
      title: title,
      assetName: assetName,
      completed: completed ?? this.completed,
      total: total ?? this.total,
      isRestricted: isRestricted ?? this.isRestricted,
    );
  }
}
