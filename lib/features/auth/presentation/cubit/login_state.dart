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
    this.route,
  });

  final String email;
  final String password;
  final bool obscurePassword;
  final LoginStatus status;
  final LoginError? error;

  /// The post-login route derived from `profile_status`. Only set when
  /// [status] is [LoginStatus.success].
  final String? route;

  bool get isValid => email.isNotEmpty && password.isNotEmpty;

  LoginState copyWith({
    String? email,
    String? password,
    bool? obscurePassword,
    LoginStatus? status,
    LoginError? error,
    String? route,
    bool clearError = false,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      status: status ?? this.status,
      error: clearError ? null : error ?? this.error,
      route: route ?? this.route,
    );
  }

  @override
  List<Object?> get props => [
    email,
    password,
    obscurePassword,
    status,
    error,
    route,
  ];
}
