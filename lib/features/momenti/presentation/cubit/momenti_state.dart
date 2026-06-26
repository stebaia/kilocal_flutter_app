part of 'momenti_cubit.dart';

enum MomentiStatus { initial, loading, loaded, error }

class MomentiState extends Equatable {
  const MomentiState({
    this.status = MomentiStatus.initial,
    this.data,
    this.error,
  });

  final MomentiStatus status;
  final MomentiData? data;
  final ApiException? error;

  MomentiState copyWith({
    MomentiStatus? status,
    MomentiData? data,
    ApiException? error,
  }) {
    return MomentiState(
      status: status ?? this.status,
      data: data ?? this.data,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, data, error];
}
