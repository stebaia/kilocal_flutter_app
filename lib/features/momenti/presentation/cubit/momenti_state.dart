part of 'momenti_cubit.dart';

enum MomentiStatus { initial, loading, loaded, error }

class MomentiState extends Equatable {
  const MomentiState({this.status = MomentiStatus.initial, this.data});

  final MomentiStatus status;
  final MomentiData? data;

  MomentiState copyWith({MomentiStatus? status, MomentiData? data}) {
    return MomentiState(status: status ?? this.status, data: data ?? this.data);
  }

  @override
  List<Object?> get props => [status, data];
}
