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
    this.fullName = '',
    this.email = '',
    this.password = '',
    this.passwordConfirm = '',
    this.obscurePassword = true,
    this.obscurePasswordConfirm = true,
    this.status = RegisterStatus.initial,
    this.error,
  });

  final String fullName;
  final String email;
  final String password;
  final String passwordConfirm;
  final bool obscurePassword;
  final bool obscurePasswordConfirm;
  final RegisterStatus status;
  final RegisterError? error;

  bool get isValid =>
      fullName.trim().isNotEmpty &&
      email.trim().isNotEmpty &&
      password.isNotEmpty &&
      passwordConfirm.isNotEmpty;

  List<String> get _nameParts => fullName.trim().split(RegExp(r'\s+'));

  String get firstName => _nameParts.isNotEmpty ? _nameParts.first : '';

  String get lastName =>
      _nameParts.length > 1 ? _nameParts.sublist(1).join(' ') : '';

  RegisterState copyWith({
    String? fullName,
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
      fullName: fullName ?? this.fullName,
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
    fullName,
    email,
    password,
    passwordConfirm,
    obscurePassword,
    obscurePasswordConfirm,
    status,
    error,
  ];
}
