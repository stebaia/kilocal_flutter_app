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
}

/// A single area inside the user path (e.g. training, nutrition, wellbeing).
class PathArea {
  const PathArea({
    required this.id,
    required this.title,
    required this.assetName,
    required this.completed,
    required this.total,
  });

  final String id;
  final String title;
  final String assetName;
  final int completed;
  final int total;

  double get progress => total == 0 ? 0 : completed / total;
}
