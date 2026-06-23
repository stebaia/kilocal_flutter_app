part of 'benefits_cubit.dart';

enum BenefitsStatus { initial, loading, loaded, error }

class BenefitsState extends Equatable {
  const BenefitsState({
    this.status = BenefitsStatus.initial,
    this.benefits = const [],
    this.error,
  });

  final BenefitsStatus status;
  final List<Benefit> benefits;
  final ApiException? error;

  /// Hero partners shown in the "Partner Primari" section.
  List<Benefit> get primaryPartners =>
      benefits.where((b) => b.mainPartner).toList();

  /// Compact rows shown in the "Partner Secondari" section.
  List<Benefit> get secondaryPartners =>
      benefits.where((b) => !b.mainPartner).toList();

  BenefitsState copyWith({
    BenefitsStatus? status,
    List<Benefit>? benefits,
    ApiException? error,
  }) {
    return BenefitsState(
      status: status ?? this.status,
      benefits: benefits ?? this.benefits,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, benefits, error];
}
