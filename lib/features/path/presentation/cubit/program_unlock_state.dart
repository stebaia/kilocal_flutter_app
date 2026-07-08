part of 'program_unlock_cubit.dart';

enum ProgramUnlockStatus {
  /// Editing the code, nothing submitted yet.
  editing,

  /// Validating / unlocking in progress.
  submitting,

  /// The entered code matched no product.
  invalidCode,

  /// The programme was unlocked.
  unlocked,

  /// A network / server error occurred while validating.
  error,
}

class ProgramUnlockState extends Equatable {
  const ProgramUnlockState({
    this.status = ProgramUnlockStatus.editing,
    this.error,
  });

  final ProgramUnlockStatus status;
  final ApiException? error;

  bool get isSubmitting => status == ProgramUnlockStatus.submitting;

  ProgramUnlockState copyWith({
    ProgramUnlockStatus? status,
    ApiException? error,
  }) {
    return ProgramUnlockState(
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, error];
}
