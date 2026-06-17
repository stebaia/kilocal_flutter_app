import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'splash_state.dart';

/// Cubit that simulates bootstrap work (settings load + session restore)
/// and then signals that the splash phase is complete.
class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(const SplashState());

  Future<void> initialize() async {
    emit(state.copyWith(status: SplashStatus.loading));
    // Simulate bootstrap delay (settings + auth check)
    await Future<void>.delayed(const Duration(seconds: 2));
    emit(state.copyWith(status: SplashStatus.ready, route: '/onboarding'));
  }
}
