import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/auth_repository.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const RegisterState());

  final AuthRepository _authRepository;

  void firstNameChanged(String value) =>
      emit(state.copyWith(firstName: value, clearError: true));

  void lastNameChanged(String value) =>
      emit(state.copyWith(lastName: value, clearError: true));

  void emailChanged(String value) =>
      emit(state.copyWith(email: value, clearError: true));

  void passwordChanged(String value) =>
      emit(state.copyWith(password: value, clearError: true));

  void passwordConfirmChanged(String value) =>
      emit(state.copyWith(passwordConfirm: value, clearError: true));

  void togglePasswordVisibility() =>
      emit(state.copyWith(obscurePassword: !state.obscurePassword));

  void togglePasswordConfirmVisibility() => emit(
    state.copyWith(obscurePasswordConfirm: !state.obscurePasswordConfirm),
  );

  Future<void> register() async {
    if (!state.isValid) {
      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          error: RegisterError.missingFields,
        ),
      );
      return;
    }

    if (state.password != state.passwordConfirm) {
      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          error: RegisterError.passwordMismatch,
        ),
      );
      return;
    }

    emit(state.copyWith(status: RegisterStatus.submitting, clearError: true));

    try {
      await _authRepository.register(
        firstName: state.firstName,
        lastName: state.lastName,
        email: state.email.trim(),
        password: state.password,
        passwordConfirm: state.passwordConfirm,
      );
      emit(state.copyWith(status: RegisterStatus.success));
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          error: _mapApiError(e.type),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          error: RegisterError.unknown,
        ),
      );
    }
  }

  RegisterError _mapApiError(ApiErrorType type) {
    switch (type) {
      case ApiErrorType.conflict:
        return RegisterError.conflict;
      case ApiErrorType.badRequest:
        return RegisterError.badRequest;
      case ApiErrorType.network:
        return RegisterError.network;
      default:
        if (type == ApiErrorType.server) {
          return RegisterError.server;
        }
        return RegisterError.unknown;
    }
  }
}
