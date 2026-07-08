import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/auth_repository.dart';

part 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const ForgotPasswordState());

  final AuthRepository _authRepository;

  void emailChanged(String value) {
    emit(state.copyWith(email: value, clearError: true));
  }

  Future<void> submit() async {
    if (!state.isValid) {
      emit(
        state.copyWith(
          status: ForgotPasswordStatus.failure,
          error: ForgotPasswordError.missingEmail,
        ),
      );
      return;
    }

    emit(state.copyWith(status: ForgotPasswordStatus.submitting, clearError: true));

    try {
      await _authRepository.requestPasswordReset(email: state.email.trim());
      emit(state.copyWith(status: ForgotPasswordStatus.success));
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          status: ForgotPasswordStatus.failure,
          error: _mapApiError(e.type),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ForgotPasswordStatus.failure,
          error: ForgotPasswordError.unknown,
        ),
      );
    }
  }

  ForgotPasswordError _mapApiError(ApiErrorType type) {
    switch (type) {
      case ApiErrorType.badRequest:
        return ForgotPasswordError.badRequest;
      case ApiErrorType.network:
        return ForgotPasswordError.network;
      case ApiErrorType.server:
        return ForgotPasswordError.server;
      default:
        return ForgotPasswordError.unknown;
    }
  }
}
