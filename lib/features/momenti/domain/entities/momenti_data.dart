class MeccanicaItem {
  const MeccanicaItem({required this.day, required this.description});

  final String day;
  final String description;
}

class MomentiData {
  const MomentiData({
    required this.title,
    required this.body,
    required this.heroImageUrl,
    required this.meccanica,
  });

  final String title;
  final String body;
  final String heroImageUrl;
  final List<MeccanicaItem> meccanica;
}