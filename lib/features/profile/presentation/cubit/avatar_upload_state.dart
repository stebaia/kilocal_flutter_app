part of 'avatar_upload_cubit.dart';

enum AvatarUploadStatus { idle, uploading, success, error }

class AvatarUploadState extends Equatable {
  const AvatarUploadState({this.status = AvatarUploadStatus.idle, this.error});

  final AvatarUploadStatus status;
  final ApiException? error;

  bool get isUploading => status == AvatarUploadStatus.uploading;

  AvatarUploadState copyWith({
    AvatarUploadStatus? status,
    ApiException? error,
  }) {
    return AvatarUploadState(
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, error];
}
