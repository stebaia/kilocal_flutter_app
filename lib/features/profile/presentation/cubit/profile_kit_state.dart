part of 'profile_kit_cubit.dart';

enum ProfileKitStatus { initial, loading, loaded, error }

class ProfileKitState extends Equatable {
  const ProfileKitState({
    this.status = ProfileKitStatus.initial,
    this.kit,
    this.error,
  });

  final ProfileKitStatus status;
  final ProfileKit? kit;
  final ApiException? error;

  ProfileKitState copyWith({
    ProfileKitStatus? status,
    ProfileKit? kit,
    ApiException? error,
  }) {
    return ProfileKitState(
      status: status ?? this.status,
      kit: kit ?? this.kit,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, kit, error];
}
