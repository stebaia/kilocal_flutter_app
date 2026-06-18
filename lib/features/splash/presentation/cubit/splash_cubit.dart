import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/network/token_store.dart';

part 'splash_state.dart';

/// Cubit that simulates bootstrap work (settings load + session restore)
/// and then signals that the splash phase is complete.
class SplashCubit extends Cubit<SplashState> {
  SplashCubit({required TokenStore tokenStore})
    : _tokenStore = tokenStore,
      super(const SplashState());

  final TokenStore _tokenStore;

  Future<void> initialize() async {
    emit(state.copyWith(status: SplashStatus.loading));

    // Simulate bootstrap delay (settings + auth check).
    await Future<void>.delayed(const Duration(seconds: 2));

    final isAuthenticated = await _tokenStore.hasSession;
    final route = isAuthenticated ? '/home' : '/onboarding';

    emit(state.copyWith(status: SplashStatus.ready, route: route));
  }
}
