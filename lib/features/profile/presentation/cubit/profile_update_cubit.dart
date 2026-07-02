import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/network/api_exception.dart';
import '../../../user/domain/user_repository.dart';
import '../../../user/presentation/cubit/user_cubit.dart';

part 'profile_update_state.dart';

/// Submits profile form values via `PATCH /profile` and refreshes the cached
/// session so the UI reflects the saved data.
class ProfileUpdateCubit extends Cubit<ProfileUpdateState> {
  ProfileUpdateCubit({
    required UserRepository userRepository,
    required UserCubit userCubit,
  }) : _userRepository = userRepository,
       _userCubit = userCubit,
       super(const ProfileUpdateState());

  final UserRepository _userRepository;
  final UserCubit _userCubit;

  Future<void> submit(Map<String, dynamic> values) async {
    emit(state.copyWith(status: ProfileUpdateStatus.submitting, error: null));
    try {
      await _userRepository.updateProfile(values);
      // Refresh /users/me + GetUserDetails so pre-filled forms stay in sync.
      await _userCubit.loadSession();
      emit(state.copyWith(status: ProfileUpdateStatus.success));
    } on ApiException catch (e) {
      emit(state.copyWith(status: ProfileUpdateStatus.error, error: e));
    }
  }

  /// Resets to idle after a success/error has been handled by the UI.
  void reset() => emit(const ProfileUpdateState());
}
