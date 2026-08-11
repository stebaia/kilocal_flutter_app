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
  /// lifetime-only and accepts no timeframe parameter.
  ///
  /// `integrazione` is phase-based: under a month filter it reports the phase
  /// whose `sort` matches the selected month, which is `0/0` while that phase
  /// is still locked (the user has not reached it yet). Without a filter it
  /// keeps its lifetime value. [myId] is the user id needed to resolve the
  /// kit/phase data; when null, `integrazione` falls back to lifetime.
  ///
  /// `benessere` is intentionally excluded from the returned list (product
  /// decision); the backend still returns it, it is just not surfaced here.
  Future<List<AreaStat>> fetchStatistics(
    AppLocalizations l10n, {
    AreaTimeframe? timeframe,
    String? myId,
  });

  /// Fetches the selectable timeframes (months/phases) for a single
  /// reference area, shown in the statistics filter bottom sheet.
  Future<List<AreaTimeframe>> fetchAreaTimeframes({
    required String area,
    required AppLocalizations l10n,
  });
}
