/// Pure domain entity representing the data shown on the home screen.
/// Populated from mock data until the CMS/API contract is defined.
class HomeData {
  const HomeData({
    required this.userName,
    required this.overallProgress,
    required this.quickCards,
    required this.heroItems,
  });

  final String userName;
  final double overallProgress; // 0..1
  final List<QuickCard> quickCards;
  final List<HeroItem> heroItems;
}

class QuickCard {
  const QuickCard({required this.title, this.subtitle, required this.icon});

  final String title;
  final String? subtitle;
  final String icon; // emoji or asset key for simplicity
}

class HeroItem {
  const HeroItem({required this.title, required this.imageUrl, this.subtitle});

  final String title;
  final String imageUrl;
  final String? subtitle;
}