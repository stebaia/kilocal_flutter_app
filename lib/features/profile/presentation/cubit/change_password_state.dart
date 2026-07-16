part of 'change_password_cubit.dart';

enum ChangePasswordStatus { initial, submitting, success, error }

/// Validation failures surfaced under the fields, before any API call.
enum ChangePasswordValidation { tooShort, mismatch }

class ChangePasswordState extends Equatable {
  const ChangePasswordState({
    this.password = '',
    this.confirmPassword = '',
    this.obscurePassword = true,
    this.obscureConfirmPassword = true,
    this.status = ChangePasswordStatus.initial,
    this.validation,
    this.error,
  });

  final String password;
  final String confirmPassword;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final ChangePasswordStatus status;
  final ChangePasswordValidation? validation;
  final ApiException? error;

  bool get isSubmitting => status == ChangePasswordStatus.submitting;

  /// Enables the submit button once both fields are non-empty; the actual rules
  /// (length, match) run on submit so the errors appear on an explicit action.
  bool get canSubmit =>
      !isSubmitting && password.isNotEmpty && confirmPassword.isNotEmpty;

  ChangePasswordState copyWith({
    String? password,
    String? confirmPassword,
    bool? obscurePassword,
    bool? obscureConfirmPassword,
    ChangePasswordStatus? status,
    ChangePasswordValidation? validation,
    ApiException? error,
    bool clearValidation = false,
    bool clearError = false,
  }) {
    return ChangePasswordState(
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirmPassword:
          obscureConfirmPassword ?? this.obscureConfirmPassword,
      status: status ?? this.status,
      validation: clearValidation ? null : validation ?? this.validation,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    password,
    confirmPassword,
    obscurePassword,
    obscureConfirmPassword,
    status,
    validation,
    error,
  ];
}
