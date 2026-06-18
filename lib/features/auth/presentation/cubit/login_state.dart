part of 'login_cubit.dart';

enum LoginStatus { initial, submitting, success, failure }

enum LoginError {
  missingFields,
  invalidCredentials,
  badRequest,
  network,
  server,
  unknown,
}

class LoginState extends Equatable {
  const LoginState({
    this.email = '',
    this.password = '',
    this.obscurePassword = true,
    this.status = LoginStatus.initial,
    this.error,
  });

  final String email;
  final String password;
  final bool obscurePassword;
  final LoginStatus status;
  final LoginError? error;

  bool get isValid => email.isNotEmpty && password.isNotEmpty;

  LoginState copyWith({
    String? email,
    String? password,
    bool? obscurePassword,
    LoginStatus? status,
    LoginError? error,
    bool clearError = false,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      status: status ?? this.status,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [email, password, obscurePassword, status, error];
}
