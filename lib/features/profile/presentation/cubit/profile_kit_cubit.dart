import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/entities/profile_kit.dart';
import '../../domain/profile_kit_repository.dart';

part 'profile_kit_state.dart';

/// Loads the user's kit (plan + supplement products) for the "Il mio Kit" and
/// "Integrazione e prodotti" screens. The kit id comes from the biotype
/// (`user_details.profile.kit.id`), passed in by the caller.
class ProfileKitCubit extends Cubit<ProfileKitState> {
  ProfileKitCubit({required ProfileKitRepository repository})
    : _repository = repository,
      super(const ProfileKitState());

  final ProfileKitRepository _repository;

  // The CMS uses codes like "it-IT"; default to Italian, matching the rest of
  // the app's GraphQL repositories.
  static const _lang = 'it-IT';

  Future<void> load(String kitId) async {
    emit(state.copyWith(status: ProfileKitStatus.loading, error: null));
    try {
      final kit = await _repository.fetchKit(kitId: kitId, lang: _lang);
      emit(state.copyWith(status: ProfileKitStatus.loaded, kit: kit));
    } on ApiException catch (e) {
      emit(state.copyWith(status: ProfileKitStatus.error, error: e));
    }
  }
}
