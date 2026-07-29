part of 'statistics_cubit.dart';

enum StatisticsStatus { initial, loading, loaded, error }

class StatisticsState extends Equatable {
  const StatisticsState({
    this.status = StatisticsStatus.initial,
    this.stats = const [],
    this.selectedTimeframe,
  });

  final StatisticsStatus status;
  final List<AreaStat> stats;

  /// The timeframe currently filtering [stats], or null when showing
  /// lifetime-aggregated progress (no filter applied).
  final AreaTimeframe? selectedTimeframe;

  StatisticsState copyWith({
    StatisticsStatus? status,
    List<AreaStat>? stats,
    AreaTimeframe? selectedTimeframe,
    bool clearSelectedTimeframe = false,
  }) {
    return StatisticsState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      selectedTimeframe: clearSelectedTimeframe
          ? null
          : selectedTimeframe ?? this.selectedTimeframe,
    );
  }

  @override
  List<Object?> get props => [status, stats, selectedTimeframe];
}
