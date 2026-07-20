part of 'promemoria_cubit.dart';

enum PromemoriaStatus { initial, loading, loaded, error }

enum PromemoriaView { list, calendar }

class PromemoriaState extends Equatable {
  const PromemoriaState({
    this.status = PromemoriaStatus.initial,
    this.reminders = const [],
    this.view = PromemoriaView.list,
    required this.focusedMonth,
  });

  final PromemoriaStatus status;
  final List<PromemoriaReminder> reminders;
  final PromemoriaView view;

  /// First day of the month currently shown in the header/calendar.
  final DateTime focusedMonth;

  /// Reminders falling within [focusedMonth], sorted ascending.
  List<PromemoriaReminder> get remindersInMonth => reminders
      .where(
        (r) =>
            r.dateTime.year == focusedMonth.year &&
            r.dateTime.month == focusedMonth.month,
      )
      .toList();

  PromemoriaState copyWith({
    PromemoriaStatus? status,
    List<PromemoriaReminder>? reminders,
    PromemoriaView? view,
    DateTime? focusedMonth,
  }) {
    return PromemoriaState(
      status: status ?? this.status,
      reminders: reminders ?? this.reminders,
      view: view ?? this.view,
      focusedMonth: focusedMonth ?? this.focusedMonth,
    );
  }

  @override
  List<Object?> get props => [status, reminders, view, focusedMonth];
}
