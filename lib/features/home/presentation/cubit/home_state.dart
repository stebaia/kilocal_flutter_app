part of 'home_cubit.dart';

enum HomeStatus { initial, loading, loaded, error }

class HomeState extends Equatable {
  const HomeState({this.status = HomeStatus.initial, this.data});

  final HomeStatus status;
  final HomeData? data;

  HomeState copyWith({HomeStatus? status, HomeData? data}) {
    return HomeState(
      status: status ?? this.status,
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [status, data];
}