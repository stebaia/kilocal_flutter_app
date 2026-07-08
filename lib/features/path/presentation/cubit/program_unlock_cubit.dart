import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/network/api_exception.dart';
import '../../../user/presentation/cubit/user_cubit.dart';
import '../../domain/entities/barcode_product.dart';
import '../../domain/program_unlock_repository.dart';

part 'program_unlock_state.dart';

/// Drives the "Sblocca il programma" sheet: validates the barcode the user
/// typed against the products flagged `use_for_barcode_check`, then unlocks.
///
/// Validation is fully client-side. On a match the unlock is persisted via
/// `PATCH /profile` (moving off `active_restricted_access`) and the session is
/// reloaded so the app re-evaluates content gating.
class ProgramUnlockCubit extends Cubit<ProgramUnlockState> {
  ProgramUnlockCubit({
    required ProgramUnlockRepository repository,
    required UserCubit userCubit,
  }) : _repository = repository,
       _userCubit = userCubit,
       super(const ProgramUnlockState());

  final ProgramUnlockRepository _repository;
  final UserCubit _userCubit;

  /// Validates [rawCode] against the barcode-check catalogue and, on a match,
  /// attempts to unlock the programme.
  Future<void> submitCode(String rawCode) async {
    final code = rawCode.trim().toUpperCase();
    if (code.isEmpty) {
      emit(state.copyWith(status: ProgramUnlockStatus.invalidCode));
      return;
    }

    emit(state.copyWith(status: ProgramUnlockStatus.submitting));

    final BarcodeProduct match;
    try {
      final products = await _repository.fetchBarcodeProducts();
      final found = products
          .where((p) => p.codes.contains(code))
          .cast<BarcodeProduct?>()
          .firstWhere((_) => true, orElse: () => null);
      if (found == null) {
        emit(state.copyWith(status: ProgramUnlockStatus.invalidCode));
        return;
      }
      match = found;
    } on ApiException catch (e) {
      emit(state.copyWith(status: ProgramUnlockStatus.error, error: e));
      return;
    }

    try {
      await _repository.unlockWithProduct(match);
      // Reload the session so `profile_status` (now off restricted access) is
      // reflected across the app and the path areas render unlocked.
      await _userCubit.loadSession();
      emit(state.copyWith(status: ProgramUnlockStatus.unlocked));
    } on ApiException catch (e) {
      emit(state.copyWith(status: ProgramUnlockStatus.error, error: e));
    }
  }

  /// Resets to the editing state after an error/invalid attempt.
  void reset() => emit(const ProgramUnlockState());
}
