import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/network/api_exception.dart';
import '../../../user/presentation/cubit/user_cubit.dart';
import '../../domain/auth_repository.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({
    required AuthRepository authRepository,
    required UserCubit userCubit,
  }) : _authRepository = authRepository,
       _userCubit = userCubit,
       super(const LoginState());

  final AuthRepository _authRepository;
  final UserCubit _userCubit;

  void emailChanged(String value) {
    emit(state.copyWith(email: value, clearError: true));
  }

  void passwordChanged(String value) {
    emit(state.copyWith(password: value, clearError: true));
  }

  void togglePasswordVisibility() =>
      emit(state.copyWith(obscurePassword: !state.obscurePassword));

  Future<void> login() async {
    if (!state.isValid) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          error: LoginError.missingFields,
        ),
      );
      return;
    }

    emit(state.copyWith(status: LoginStatus.submitting, clearError: true));

    try {
      await _authRepository.login(
        email: state.email.trim(),
        password: state.password,
      );

      await _userCubit.loadSession();

      emit(
        state.copyWith(
          status: LoginStatus.success,
          route: _userCubit.state.route ?? '/home',
        ),
      );
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          error: _mapApiError(e.type),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(status: LoginStatus.failure, error: LoginError.unknown),
      );
    }
  }

  LoginError _mapApiError(ApiErrorType type) {
    switch (type) {
      case ApiErrorType.unauthorized:
        return LoginError.invalidCredentials;
      case ApiErrorType.badRequest:
        return LoginError.badRequest;
      case ApiErrorType.network:
        return LoginError.network;
      default:
        if (type == ApiErrorType.server) {
          return LoginError.server;
        }
        return LoginError.unknown;
    }
  }
}
