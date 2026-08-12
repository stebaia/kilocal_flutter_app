import '../../../l10n/app_localizations.dart';
import 'entities/area_stat.dart';

/// Repository contract for the statistics screen.
abstract class StatisticsRepository {
  /// Fetches per-area completion stats from `GET /path/me/progress`.
  ///
  /// When [timeframe] is null the endpoint returns lifetime-aggregated
  /// progress; when provided, its id is passed as `timeframe_id` and the
  /// backend scopes every area to that month. Nothing is recomputed
  /// client-side, `integrazione` included — it is reported in content steps
  /// like every other area, not in supplement intake days.
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
