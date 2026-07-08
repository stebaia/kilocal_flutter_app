part of 'forgot_password_cubit.dart';

enum ForgotPasswordStatus { initial, submitting, success, failure }

enum ForgotPasswordError { missingEmail, badRequest, network, server, unknown }

class ForgotPasswordState extends Equatable {
  const ForgotPasswordState({
    this.email = '',
    this.status = ForgotPasswordStatus.initial,
    this.error,
  });

  final String email;
  final ForgotPasswordStatus status;
  final ForgotPasswordError? error;

  bool get isValid => email.trim().isNotEmpty;

  ForgotPasswordState copyWith({
    String? email,
    ForgotPasswordStatus? status,
    ForgotPasswordError? error,
    bool clearError = false,
  }) {
    return ForgotPasswordState(
      email: email ?? this.email,
      status: status ?? this.status,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [email, status, error];
}
