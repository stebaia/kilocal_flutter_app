import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/network/api_exception.dart';
import '../../../user/domain/user_repository.dart';

part 'change_password_state.dart';

/// Sets a new account password via `PATCH /users/me`.
///
/// There is intentionally no "current password" field: the API authorises the
/// change on the access token alone and offers no way to verify the old
/// password, so asking for it would only be checked client-side. See
/// [UserRepository.changePassword].
class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit({required UserRepository userRepository})
    : _userRepository = userRepository,
      super(const ChangePasswordState());

  final UserRepository _userRepository;

  /// Directus rejects shorter passwords; keep in sync with the CMS policy.
  static const minPasswordLength = 8;

  void passwordChanged(String value) => emit(
    state.copyWith(password: value, clearValidation: true, clearError: true),
  );

  void confirmPasswordChanged(String value) => emit(
    state.copyWith(
      confirmPassword: value,
      clearValidation: true,
      clearError: true,
    ),
  );

  void toggleObscurePassword() =>
      emit(state.copyWith(obscurePassword: !state.obscurePassword));

  void toggleObscureConfirmPassword() => emit(
    state.copyWith(obscureConfirmPassword: !state.obscureConfirmPassword),
  );

  Future<void> submit() async {
    if (state.isSubmitting) return;

    if (state.password.length < minPasswordLength) {
      emit(state.copyWith(validation: ChangePasswordValidation.tooShort));
      return;
    }
    if (state.password != state.confirmPassword) {
      emit(state.copyWith(validation: ChangePasswordValidation.mismatch));
      return;
    }

    emit(
      state.copyWith(
        status: ChangePasswordStatus.submitting,
        clearValidation: true,
        clearError: true,
      ),
    );
    try {
      await _userRepository.changePassword(state.password);
      emit(state.copyWith(status: ChangePasswordStatus.success));
    } on ApiException catch (e) {
      emit(state.copyWith(status: ChangePasswordStatus.error, error: e));
    }
  }

  /// Resets to idle after a success/error has been handled by the UI.
  void reset() => emit(const ChangePasswordState());
}
