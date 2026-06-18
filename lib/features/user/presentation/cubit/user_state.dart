part of 'user_cubit.dart';

enum UserStatus { initial, loading, loaded, error }

class UserState extends Equatable {
  const UserState({
    this.status = UserStatus.initial,
    this.user,
    this.details,
    this.error,
  });

  final UserStatus status;
  final AppUser? user;
  final UserDetails? details;
  final ApiException? error;

  ProfileStatus get profileStatus =>
      details?.profileStatus ?? ProfileStatus.unknown;

  /// The post-login route implied by the current profile status.
  String? get route => profileStatus.route;

  /// Whether tools should be blocked for the current profile status.
  bool get isToolBlocked => profileStatus.isToolBlocked;

  UserState copyWith({
    UserStatus? status,
    AppUser? user,
    UserDetails? details,
    ApiException? error,
  }) {
    return UserState(
      status: status ?? this.status,
      user: user ?? this.user,
      details: details ?? this.details,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, user, details, error];
}
