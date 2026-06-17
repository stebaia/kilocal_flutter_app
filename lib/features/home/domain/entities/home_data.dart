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
    required this.subtitle,
    required this.imageUrl,
  });

  final String title;
  final String subtitle;
  final String imageUrl;
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
  });

  final String title;
  final String imageUrl;
  final String route;

  /// Optional local asset used as the card illustration.
  /// When provided, it takes precedence over [imageUrl].
  final String? assetName;
}
