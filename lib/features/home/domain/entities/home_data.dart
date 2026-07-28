/// Pure domain entity representing the data shown on the home screen.
/// Populated from mock data until the CMS/API contract is defined.
class HomeData {
  const HomeData({
    required this.userName,
    required this.currentDate,
    required this.continuePath,
    required this.monthStats,
    required this.actionCards,
  });

  final String userName;
  final DateTime currentDate;
  final ContinuePathItem continuePath;
  final MonthStats monthStats;
  final List<HomeActionCard> actionCards;
}

/// The large pink "continue the path" hero card.
class ContinuePathItem {
  const ContinuePathItem({
    required this.title,
    this.subtitle,
    required this.imageUrl,
    this.hasStarted = false,
  });

  final String title;
  final String? subtitle;
  final String imageUrl;

  /// Whether the user has completed at least one step in any path area.
  /// Drives the CTA label: "Inizia il percorso" vs "Continua il percorso".
  final bool hasStarted;
}

/// Statistics summary for the current month.
class MonthStats {
  const MonthStats({
    required this.monthLabel,
    required this.description,
    required this.progress,
  });

  final String monthLabel;
  final String description;
  final double progress; // 0..1
}

/// Small actionable card shown on the home grid (Momenti, Benefit, ...).
class HomeActionCard {
  const HomeActionCard({
    required this.title,
    required this.imageUrl,
    required this.route,
    this.assetName,
    this.isLocked = false,
  });

  final String title;
  final String imageUrl;
  final String route;

  /// Optional local asset used as the card illustration.
  /// When provided, it takes precedence over [imageUrl].
  final String? assetName;

  /// When true, tapping the card shows a "coming soon" alert instead of
  /// navigating to [route].
  final bool isLocked;
}
