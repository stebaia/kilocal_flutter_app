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
      final stats = await _statisticsRepository.fetchStatistics(l10n);
      emit(StatisticsState(status: StatisticsStatus.loaded, stats: stats));
    } catch (_) {
      emit(state.copyWith(status: StatisticsStatus.error));
    }
  }
}
