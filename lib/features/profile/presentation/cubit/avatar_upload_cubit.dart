import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/network/api_exception.dart';
import '../../../user/domain/user_repository.dart';
import '../../../user/presentation/cubit/user_cubit.dart';

part 'avatar_upload_state.dart';

/// Picks an image, uploads it via `POST /files`, sets it as the current user's
/// avatar via `PATCH /users/me`, then refreshes the cached session so the
/// profile header reflects the new photo. See [[avatar-upload-flow]].
class AvatarUploadCubit extends Cubit<AvatarUploadState> {
  AvatarUploadCubit({
    required UserRepository userRepository,
    required UserCubit userCubit,
    ImagePicker? imagePicker,
  }) : _userRepository = userRepository,
       _userCubit = userCubit,
       _imagePicker = imagePicker ?? ImagePicker(),
       super(const AvatarUploadState());

  final UserRepository _userRepository;
  final UserCubit _userCubit;
  final ImagePicker _imagePicker;

  /// Prompts the user to pick an image from [source], uploads it and refreshes
  /// the session. Does nothing if the user cancels the picker.
  Future<void> pickAndUpload(ImageSource source) async {
    final XFile? picked = await _imagePicker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;

    emit(state.copyWith(status: AvatarUploadStatus.uploading, error: null));
    try {
      final bytes = await picked.readAsBytes();
      await _userRepository.updateAvatar(
        imageBytes: bytes,
        filename: picked.name,
      );
      // Re-fetch /users/me so AppUser.avatarUrl (and the header) update.
      await _userCubit.loadSession();
      emit(state.copyWith(status: AvatarUploadStatus.success));
    } on ApiException catch (e) {
      emit(state.copyWith(status: AvatarUploadStatus.error, error: e));
    }
  }

  /// Resets to idle after a success/error has been handled by the UI.
  void reset() => emit(const AvatarUploadState());
}
