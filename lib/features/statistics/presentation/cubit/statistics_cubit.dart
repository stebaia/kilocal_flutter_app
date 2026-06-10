import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/area_stat.dart';

part 'statistics_state.dart';

class StatisticsCubit extends Cubit<StatisticsState> {
  StatisticsCubit({List<AreaStat>? initialData})
      : super(StatisticsState(stats: initialData ?? const []));

  void loadWithData(List<AreaStat> data) {
    emit(StatisticsState(status: StatisticsStatus.loaded, stats: data));
  }

  Future<void> load() async {
    if (state.stats.isNotEmpty) {
      emit(state.copyWith(status: StatisticsStatus.loaded));
      return;
    }
    emit(state.copyWith(status: StatisticsStatus.loading));
    // TODO: call repository when backend is ready
  }
}