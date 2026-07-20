import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../../core/network/api_exception.dart';
import '../../domain/entities/promemoria_reminder.dart';
import '../../domain/promemoria_repository.dart';

part 'promemoria_state.dart';

class PromemoriaCubit extends Cubit<PromemoriaState> {
  PromemoriaCubit({required PromemoriaRepository repository})
    : _repository = repository,
      super(PromemoriaState(focusedMonth: _monthOf(DateTime.now())));

  final PromemoriaRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: PromemoriaStatus.loading));
    try {
      final reminders = await _repository.getAll();
      emit(
        state.copyWith(status: PromemoriaStatus.loaded, reminders: reminders),
      );
    } on ApiException {
      emit(state.copyWith(status: PromemoriaStatus.error));
    }
  }

  Future<void> add(PromemoriaInput input) async {
    final reminders = await _repository.add(input);
    // Follow the newly-added reminder's month so it's visible after creating.
    emit(
      state.copyWith(
        reminders: reminders,
        focusedMonth: _monthOf(input.dateTime),
      ),
    );
  }

  Future<void> update(
    PromemoriaReminder reminder,
    PromemoriaInput input,
  ) async {
    final reminders = await _repository.update(reminder, input);
    emit(
      state.copyWith(
        reminders: reminders,
        focusedMonth: _monthOf(input.dateTime),
      ),
    );
  }

  Future<void> delete(PromemoriaReminder reminder) async {
    await _repository.delete(reminder);
    final reminders = await _repository.getAll();
    emit(state.copyWith(reminders: reminders));
  }

  void toggleView() {
    emit(
      state.copyWith(
        view: state.view == PromemoriaView.list
            ? PromemoriaView.calendar
            : PromemoriaView.list,
      ),
    );
  }

  void previousMonth() {
    final m = state.focusedMonth;
    emit(state.copyWith(focusedMonth: DateTime(m.year, m.month - 1)));
  }

  void nextMonth() {
    final m = state.focusedMonth;
    emit(state.copyWith(focusedMonth: DateTime(m.year, m.month + 1)));
  }

  static DateTime _monthOf(DateTime d) => DateTime(d.year, d.month);
}
