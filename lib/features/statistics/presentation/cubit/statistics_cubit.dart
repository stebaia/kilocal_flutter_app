import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/area_stat.dart';
import '../../domain/statistics_repository.dart';

part 'statistics_state.dart';

class StatisticsCubit extends Cubit<StatisticsState> {
  StatisticsCubit({
    required StatisticsRepository statisticsRepository,
    List<AreaStat>? initialData,
  }) : _statisticsRepository = statisticsRepository,
       super(StatisticsState(stats: initialData ?? const []));

  final StatisticsRepository _statisticsRepository;

  /// Seeds the cubit with ready-made data (used by tests).
  void loadWithData(List<AreaStat> data) {
    emit(StatisticsState(status: StatisticsStatus.loaded, stats: data));
  }

  Future<void> load(AppLocalizations l10n) async {
    emit(state.copyWith(status: StatisticsStatus.loading));
    try {
      final stats = await _statisticsRepository.fetchStatistics(
        l10n,
        timeframeId: state.selectedTimeframe?.id,
      );
      emit(state.copyWith(status: StatisticsStatus.loaded, stats: stats));
    } catch (_) {
      emit(state.copyWith(status: StatisticsStatus.error));
    }
  }

  /// Fetches the reference area's selectable timeframes for the filter sheet.
  Future<List<AreaTimeframe>> fetchTimeframes(
    AppLocalizations l10n, {
    required String referenceArea,
  }) {
    return _statisticsRepository.fetchAreaTimeframes(
      area: referenceArea,
      l10n: l10n,
    );
  }

  /// Applies (or clears, when [timeframe] is null) the timeframe filter and
  /// reloads every area's stats.
  Future<void> selectTimeframe(AppLocalizations l10n, AreaTimeframe? timeframe) {
    emit(
      state.copyWith(
        selectedTimeframe: timeframe,
        clearSelectedTimeframe: timeframe == null,
      ),
    );
    return load(l10n);
  }
}
