part of 'register_cubit.dart';

enum RegisterStatus { initial, submitting, success, failure }

enum RegisterError {
  missingFields,
  passwordMismatch,
  conflict,
  badRequest,
  network,
  server,
  unknown,
}

class RegisterState extends Equatable {
  const RegisterState({
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.password = '',
    this.passwordConfirm = '',
    this.obscurePassword = true,
    this.obscurePasswordConfirm = true,
    this.status = RegisterStatus.initial,
    this.error,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String passwordConfirm;
  final bool obscurePassword;
  final bool obscurePasswordConfirm;
  final RegisterStatus status;
  final RegisterError? error;

  bool get isValid =>
      firstName.trim().isNotEmpty &&
      lastName.trim().isNotEmpty &&
      email.trim().isNotEmpty &&
      password.isNotEmpty &&
      passwordConfirm.isNotEmpty;

  RegisterState copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    String? passwordConfirm,
    bool? obscurePassword,
    bool? obscurePasswordConfirm,
    RegisterStatus? status,
    RegisterError? error,
    bool clearError = false,
  }) {
    return RegisterState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      passwordConfirm: passwordConfirm ?? this.passwordConfirm,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscurePasswordConfirm:
          obscurePasswordConfirm ?? this.obscurePasswordConfirm,
      status: status ?? this.status,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    email,
    password,
    passwordConfirm,
    obscurePassword,
    obscurePasswordConfirm,
    status,
    error,
  ];
}
