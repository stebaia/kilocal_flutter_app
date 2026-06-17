part of 'statistics_cubit.dart';

enum StatisticsStatus { initial, loading, loaded, error }

class StatisticsState extends Equatable {
  const StatisticsState({
    this.status = StatisticsStatus.initial,
    this.stats = const [],
  });

  final StatisticsStatus status;
  final List<AreaStat> stats;

  StatisticsState copyWith({StatisticsStatus? status, List<AreaStat>? stats}) {
    return StatisticsState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
    );
  }

  @override
  List<Object?> get props => [status, stats];
}
