import '../../../l10n/app_localizations.dart';
import '../domain/entities/path_data.dart';

/// Localized fallback data for the path screen.
///
/// This factory is used by [PathRepositoryImpl] until the backend exposes the
/// path collection. Keeping the mock data here (instead of inside the widgets)
/// makes the screen fully data-driven.
abstract final class PathMockDataFactory {
  PathMockDataFactory._();

  static PathData build(AppLocalizations l10n) {
    return PathData(
      overallCompleted: 23,
      overallTotal: 132,
      headerAssetName: 'assets/path_header_ellipse.svg',
      areas: [
        PathArea(
          id: 'training',
          title: l10n.areaTraining,
          assetName: 'assets/training.png',
          completed: 3,
          total: 34,
        ),
        PathArea(
          id: 'nutrition',
          title: l10n.areaNutrition,
          assetName: 'assets/alimentation.png',
          completed: 1,
          total: 28,
        ),
        PathArea(
          id: 'wellbeing',
          title: l10n.areaWellbeing,
          assetName: 'assets/wellness.png',
          completed: 1,
          total: 27,
        ),
        PathArea(
          id: 'integration',
          title: l10n.areaIntegration,
          assetName: 'assets/name_logo.png',
          completed: 5,
          total: 26,
        ),
      ],
    );
  }
}
