part of 'profile_update_cubit.dart';

enum ProfileUpdateStatus { idle, submitting, success, error }

class ProfileUpdateState extends Equatable {
  const ProfileUpdateState({
    this.status = ProfileUpdateStatus.idle,
    this.error,
  });

  final ProfileUpdateStatus status;
  final ApiException? error;

  bool get isSubmitting => status == ProfileUpdateStatus.submitting;

  ProfileUpdateState copyWith({
    ProfileUpdateStatus? status,
    ApiException? error,
  }) {
    return ProfileUpdateState(
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, error];
}
