part of 'splash_cubit.dart';

enum SplashStatus { initial, loading, ready }

class SplashState extends Equatable {
  const SplashState({this.status = SplashStatus.initial, this.route});

  final SplashStatus status;
  final String? route;

  SplashState copyWith({SplashStatus? status, String? route}) =>
      SplashState(status: status ?? this.status, route: route ?? this.route);

  @override
  List<Object?> get props => [status, route];
}
