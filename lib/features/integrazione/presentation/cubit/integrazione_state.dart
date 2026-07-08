part of 'integrazione_cubit.dart';

enum IntegrazioneStatus { initial, loading, loaded, error }

class IntegrazioneState extends Equatable {
  const IntegrazioneState({
    this.status = IntegrazioneStatus.initial,
    this.data,
    this.error,
  });

  final IntegrazioneStatus status;
  final IntegrazioneData? data;
  final ApiException? error;

  IntegrazioneState copyWith({
    IntegrazioneStatus? status,
    IntegrazioneData? data,
    ApiException? error,
  }) {
    return IntegrazioneState(
      status: status ?? this.status,
      data: data ?? this.data,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, data, error];
}
