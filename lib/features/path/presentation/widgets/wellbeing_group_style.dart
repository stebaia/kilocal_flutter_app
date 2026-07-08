import '../../../../core/icons/app_icons.dart';

/// Illustration asset and header icon for a Benessere sub-section card.
///
/// The backend returns the wellbeing groups (Mindfulness / Self care / Stili di
/// vita) in a fixed order but without these 3D illustrations, so the visuals are
/// mapped client-side. Mapping is by position first (matching the design order)
/// and falls back to a keyword match on the group title so a reordered or
/// renamed group still gets the right artwork.
class WellbeingGroupStyle {
  const WellbeingGroupStyle({required this.assetName, required this.iconName});

  final String assetName;
  final String iconName;

  static const _byIndex = <WellbeingGroupStyle>[
    WellbeingGroupStyle(
      assetName: 'assets/mindfulness.png',
      iconName: AppIcons.mindfulness,
    ),
    WellbeingGroupStyle(
      assetName: 'assets/self_care.png',
      iconName: AppIcons.selfCare,
    ),
    WellbeingGroupStyle(
      assetName: 'assets/lifestyle.png',
      iconName: AppIcons.lifestyle,
    ),
  ];

  /// Resolves the style for a group given its [title] and [index] in the list.
  static WellbeingGroupStyle of(String title, int index) {
    final normalized = title.toLowerCase();
    if (normalized.contains('mindful')) return _byIndex[0];
    if (normalized.contains('self') || normalized.contains('care')) {
      return _byIndex[1];
    }
    if (normalized.contains('stili') ||
        normalized.contains('vita') ||
        normalized.contains('lifestyle')) {
      return _byIndex[2];
    }
    return _byIndex[index % _byIndex.length];
  }
}
