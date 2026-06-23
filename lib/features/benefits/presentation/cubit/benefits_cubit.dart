import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/benefits_repository.dart';
import '../../domain/entities/benefit.dart';

part 'benefits_state.dart';

class BenefitsCubit extends Cubit<BenefitsState> {
  BenefitsCubit({required BenefitsRepository benefitsRepository})
    : _benefitsRepository = benefitsRepository,
      super(const BenefitsState());

  final BenefitsRepository _benefitsRepository;

  Future<void> load() async {
    emit(state.copyWith(status: BenefitsStatus.loading, error: null));

    try {
      final benefits = await _benefitsRepository.fetchBenefits();
      emit(state.copyWith(status: BenefitsStatus.loaded, benefits: benefits));
    } on ApiException catch (e) {
      emit(state.copyWith(status: BenefitsStatus.error, error: e));
    }
  }
}
