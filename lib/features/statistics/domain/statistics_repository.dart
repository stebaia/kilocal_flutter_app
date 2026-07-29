import '../../../l10n/app_localizations.dart';
import 'entities/area_stat.dart';

/// Repository contract for the statistics screen.
abstract class StatisticsRepository {
  /// Fetches per-area completion stats.
  ///
  /// When [timeframe] is null, returns lifetime-aggregated progress
  /// (`GET /path/me/progress`). When provided, recomputes the step-based
  /// areas' progress for that month from GraphQL (completed `user_activities`
  /// + `percorsi_content` on `timeframe.sort`) — the progress endpoint is
  /// lifetime-only and accepts no timeframe parameter. `integrazione` is
  /// phase-based and keeps its lifetime value in both cases.
  ///
  /// `benessere` is intentionally excluded from the returned list (product
  /// decision); the backend still returns it, it is just not surfaced here.
  Future<List<AreaStat>> fetchStatistics(
    AppLocalizations l10n, {
    AreaTimeframe? timeframe,
  });

  /// Fetches the selectable timeframes (months/phases) for a single
  /// reference area, shown in the statistics filter bottom sheet.
  Future<List<AreaTimeframe>> fetchAreaTimeframes({
    required String area,
    required AppLocalizations l10n,
  });
}
