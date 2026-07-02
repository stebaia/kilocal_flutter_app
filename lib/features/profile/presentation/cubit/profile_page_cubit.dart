import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/entities/profile_page.dart';
import '../../domain/profile_page_repository.dart';

part 'profile_page_state.dart';

/// Loads a CMS-driven profile page (`private_pages`) by `internal_name`.
class ProfilePageCubit extends Cubit<ProfilePageState> {
  ProfilePageCubit({required ProfilePageRepository repository})
    : _repository = repository,
      super(const ProfilePageState());

  final ProfilePageRepository _repository;

  Future<void> load(String internalName) async {
    emit(state.copyWith(status: ProfilePageStatus.loading));
    try {
      final page = await _repository.fetchPage(internalName);
      emit(state.copyWith(status: ProfilePageStatus.loaded, page: page));
    } on ApiException catch (e) {
      emit(state.copyWith(status: ProfilePageStatus.error, error: e));
    }
  }
}
