/// Domain entity representing a single area statistic.
class AreaStat {
  const AreaStat({
    required this.id,
    required this.area,
    required this.assetName,
    required this.month,
    required this.completed,
    required this.total,
  });

  /// Area key matching `root.internal_name` (`allenamento`, `alimentazione`,
  /// `integrazione`).
  final String id;

  /// Localized area title shown on the card.
  final String area;

  /// Path of the SVG icon shown next to the title.
  final String assetName;

  /// Timeframe/phase label (e.g. `Mese 1`, `Fase 1`).
  final String month;

  final int completed;
  final int total;

  double get percent => total == 0 ? 0 : completed / total;
}

/// A selectable timeframe (month/phase), shown in the statistics filter
/// bottom sheet. Selecting one refetches every area's stats filtered via
/// `GET /path/me/progress?timeframe_id=`.
class AreaTimeframe {
  const AreaTimeframe({
    required this.id,
    required this.title,
    this.isCurrent = false,
  });

  final int id;
  final String title;
  final bool isCurrent;
}
