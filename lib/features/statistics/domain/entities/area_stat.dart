/// Domain entity representing a single area statistic.
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