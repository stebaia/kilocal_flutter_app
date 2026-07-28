import '../../../l10n/app_localizations.dart';
import 'entities/area_stat.dart';

/// Repository contract for the statistics screen.
abstract class StatisticsRepository {
  /// Fetches per-area completion stats.
  ///
  /// When [timeframeId] is null, returns lifetime-aggregated progress
  /// (`GET /path/me/progress`). When provided, returns progress filtered to
  /// that timeframe (`GET /path/me/progress?timeframe_id=`) for every area.
  ///
  /// `benessere` is intentionally excluded from the returned list (product
  /// decision); the backend still returns it, it is just not surfaced here.
  Future<List<AreaStat>> fetchStatistics(
    AppLocalizations l10n, {
    int? timeframeId,
  });

  /// Fetches the selectable timeframes (months/phases) for a single
  /// reference area, shown in the statistics filter bottom sheet.
  Future<List<AreaTimeframe>> fetchAreaTimeframes({
    required String area,
    required AppLocalizations l10n,
  });
}
