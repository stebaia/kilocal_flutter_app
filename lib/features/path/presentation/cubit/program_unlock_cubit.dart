import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/entities/barcode_product.dart';
import '../../domain/program_unlock_repository.dart';

part 'program_unlock_state.dart';

/// Drives the "Sblocca il programma" sheet: validates the barcode the user
/// typed against the products flagged `use_for_barcode_check`, then unlocks.
///
/// Validation is fully client-side. The final unlock persistence is a stub in
/// the repository (pending the backend contract), so a valid code currently
/// surfaces [ProgramUnlockStatus.unlockUnavailable] rather than success.
class ProgramUnlockCubit extends Cubit<ProgramUnlockState> {
  ProgramUnlockCubit({required ProgramUnlockRepository repository})
    : _repository = repository,
      super(const ProgramUnlockState());

  final ProgramUnlockRepository _repository;

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
      emit(state.copyWith(status: ProgramUnlockStatus.unlocked));
    } on ApiException catch (e) {
      // The unlock persistence is not implemented yet (stubbed 501): the code
      // was valid but we cannot complete the unlock. Surface a distinct state
      // so the UI can explain the pending backend rather than "wrong code".
      if (e.statusCode == 501) {
        emit(state.copyWith(status: ProgramUnlockStatus.unlockUnavailable));
      } else {
        emit(state.copyWith(status: ProgramUnlockStatus.error, error: e));
      }
    }
  }

  /// Resets to the editing state after an error/invalid attempt.
  void reset() => emit(const ProgramUnlockState());
}
