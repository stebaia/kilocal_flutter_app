part of 'profile_page_cubit.dart';

enum ProfilePageStatus { initial, loading, loaded, error }

class ProfilePageState extends Equatable {
  const ProfilePageState({
    this.status = ProfilePageStatus.initial,
    this.page,
    this.error,
  });

  final ProfilePageStatus status;
  final ProfilePage? page;
  final ApiException? error;

  ProfilePageState copyWith({
    ProfilePageStatus? status,
    ProfilePage? page,
    ApiException? error,
  }) {
    return ProfilePageState(
      status: status ?? this.status,
      page: page ?? this.page,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, page, error];
}
