import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/app_user.dart';
import '../../domain/profile_status.dart';
import '../../domain/user_details.dart';
import '../../domain/user_repository.dart';

part 'user_state.dart';

/// Session-wide cubit that caches the authenticated user and their details.
///
/// Registered as a lazy singleton in `lib/app/di.dart`. It is populated after a
/// successful login and on app restart when a token is present. Call [clear] on
/// logout to reset the cached session.
class UserCubit extends Cubit<UserState> {
  UserCubit({required UserRepository userRepository})
    : _userRepository = userRepository,
      super(const UserState());

  final UserRepository _userRepository;

  String? _myId;

  /// The cached Directus user id (`myId`) used as a variable for GraphQL
  /// profile/percorso queries. `null` before [loadSession] succeeds.
  String? get myId => _myId;

  /// Loads the user session: `GET /users/me` then `GetUserDetails`.
  ///
  /// On success caches `myId` and emits [UserStatus.loaded]. On error emits
  /// [UserStatus.error] and rethrows the [ApiException] so callers can decide
  /// routing (e.g. send the user back to `/login` on a 401).
  Future<void> loadSession() async {
    emit(state.copyWith(status: UserStatus.loading));

    try {
      final user = await _userRepository.fetchCurrentUser();
      _myId = user.id;

      final details = await _userRepository.fetchUserDetails(_myId!);

      emit(
        state.copyWith(
          status: UserStatus.loaded,
          user: user,
          details: details,
          error: null,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(status: UserStatus.error, error: e));
      rethrow;
    }
  }

  /// Clears the cached session. Must be called on logout.
  void clear() {
    _myId = null;
    emit(const UserState());
  }
}
