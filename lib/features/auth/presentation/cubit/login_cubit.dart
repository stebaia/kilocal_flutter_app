import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(const LoginState());

  void emailChanged(String value) {
    emit(state.copyWith(email: value));
  }

  void passwordChanged(String value) {
    emit(state.copyWith(password: value));
  }

  Future<void> login() async {
    emit(state.copyWith(status: LoginStatus.submitting));
    // Simulate API call
    await Future<void>.delayed(const Duration(seconds: 1));
    emit(state.copyWith(status: LoginStatus.success));
  }
}