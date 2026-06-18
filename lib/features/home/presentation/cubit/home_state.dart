part of 'home_cubit.dart';

enum HomeStatus { initial, loading, loaded, error }

class HomeState extends Equatable {
  const HomeState({this.status = HomeStatus.initial, this.data, this.error});

  final HomeStatus status;
  final HomeData? data;
  final ApiException? error;

  HomeState copyWith({
    HomeStatus? status,
    HomeData? data,
    ApiException? error,
  }) {
    return HomeState(
      status: status ?? this.status,
      data: data ?? this.data,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, data, error];
}
