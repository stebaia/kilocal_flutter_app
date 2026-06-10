part of 'login_cubit.dart';

enum LoginStatus { initial, submitting, success, failure }

class LoginState extends Equatable {
  const LoginState({
    this.email = '',
    this.password = '',
    this.status = LoginStatus.initial,
  });

  final String email;
  final String password;
  final LoginStatus status;

  LoginState copyWith({String? email, String? password, LoginStatus? status}) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [email, password, status];
}