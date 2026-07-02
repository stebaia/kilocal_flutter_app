import '../../../l10n/app_localizations.dart';
import 'entities/area_stat.dart';

/// Repository contract for the statistics screen.
abstract class StatisticsRepository {
  /// Fetches per-area completion stats for the current month.
  ///
  /// `benessere` is intentionally excluded from the returned list (product
  /// decision); the backend still returns it, it is just not surfaced here.
  Future<List<AreaStat>> fetchStatistics(AppLocalizations l10n);
}
