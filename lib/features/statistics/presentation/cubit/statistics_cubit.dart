import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'statistics_state.dart';

class AreaStat {
  const AreaStat({
    required this.area,
    required this.month,
    required this.completed,
    required this.total,
  });

  final String area;
  final String month;
  final int completed;
  final int total;

  double get percent => total == 0 ? 0 : completed / total;
}

class StatisticsCubit extends Cubit<StatisticsState> {
  StatisticsCubit() : super(const StatisticsState());

  Future<void> load() async {
    emit(state.copyWith(status: StatisticsStatus.loading));
    await Future<void>.delayed(const Duration(milliseconds: 600));
    emit(
      state.copyWith(
        status: StatisticsStatus.loaded,
        stats: const [
          AreaStat(area: 'Allenamento', month: 'Mese 1', completed: 3, total: 15),
          AreaStat(area: 'Alimentazione', month: 'Mese 1', completed: 5, total: 18),
          AreaStat(area: 'Benessere', month: 'Mese 1', completed: 8, total: 25),
          AreaStat(area: 'Integrazione', month: 'Fase 1', completed: 5, total: 19),
        ],
      ),
    );
  }
}