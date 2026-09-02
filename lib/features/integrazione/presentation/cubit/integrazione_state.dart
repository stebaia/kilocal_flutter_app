part of 'integrazione_cubit.dart';

enum IntegrazioneStatus { initial, loading, loaded, error }

class IntegrazioneState extends Equatable {
  const IntegrazioneState({
    this.status = IntegrazioneStatus.initial,
    this.data,
    this.error,
    this.monthEndPending,
  });

  final IntegrazioneStatus status;
  final IntegrazioneData? data;
  final ApiException? error;
  final SurveyMonthEndPending? monthEndPending;

  IntegrazioneState copyWith({
    IntegrazioneStatus? status,
    IntegrazioneData? data,
    ApiException? error,
    SurveyMonthEndPending? monthEndPending,
    bool clearMonthEndPending = false,
  }) {
    return IntegrazioneState(
      status: status ?? this.status,
      data: data ?? this.data,
      error: error,
      monthEndPending: clearMonthEndPending
          ? null
          : (monthEndPending ?? this.monthEndPending),
    );
  }

  @override
  List<Object?> get props => [status, data, error, monthEndPending];
}
