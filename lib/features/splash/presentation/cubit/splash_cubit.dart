import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/token_store.dart';
import '../../../user/presentation/cubit/user_cubit.dart';

part 'splash_state.dart';

/// Cubit that simulates bootstrap work (settings load + session restore)
/// and then signals that the splash phase is complete.
class SplashCubit extends Cubit<SplashState> {
  SplashCubit({required TokenStore tokenStore, required UserCubit userCubit})
    : _tokenStore = tokenStore,
      _userCubit = userCubit,
      super(const SplashState());

  final TokenStore _tokenStore;
  final UserCubit _userCubit;

  Future<void> initialize() async {
    emit(state.copyWith(status: SplashStatus.loading));

    // Simulate bootstrap delay (settings + auth check).
    await Future<void>.delayed(const Duration(seconds: 2));

    final isAuthenticated = await _tokenStore.hasSession;
    if (!isAuthenticated) {
      emit(state.copyWith(status: SplashStatus.ready, route: '/onboarding'));
      return;
    }

    try {
      await _userCubit.loadSession();
      emit(
        state.copyWith(
          status: SplashStatus.ready,
          route:  _userCubit.state.route ?? '/home'  // _userCubit.state.route ?? '/home',
        ),
      );
    } on ApiException {
      // If the stored token cannot be refreshed, the interceptor already routes
      // to `/login`. Fall back to `/login` here as a safety net.
      emit(state.copyWith(status: SplashStatus.ready, route: '/login'));
    }
  }
}
