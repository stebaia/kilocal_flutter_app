import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/network/api_exception.dart';
import '../../../survey/domain/entities/survey_answer.dart';
import '../../../user/presentation/cubit/user_cubit.dart';
import '../../domain/entities/integrazione_data.dart';
import '../../domain/integrazione_repository.dart';
import '../../../survey/domain/survey_repository.dart';

part 'integrazione_state.dart';

/// Cubit that loads the user's supplement plan (phases + products) for the
/// "Integrazione" area. See [[integrazione]].
class IntegrazioneCubit extends Cubit<IntegrazioneState> {
  IntegrazioneCubit({
    required IntegrazioneRepository repository,
    required UserCubit userCubit,
    required SurveyRepository surveyRepository,
  }) : _repository = repository,
       _userCubit = userCubit,
       _surveyRepository = surveyRepository,
       super(const IntegrazioneState());

  final IntegrazioneRepository _repository;
  final UserCubit _userCubit;
  final SurveyRepository _surveyRepository;

  // The CMS uses codes like "it-IT" / "en-US". Default to Italian for now,
  // matching the rest of the app's GraphQL repositories.
  static const _lang = 'it-IT';

  Future<void> load() async {
    emit(state.copyWith(status: IntegrazioneStatus.loading, error: null));

    final user = _userCubit.state.user;
    if (user == null) {
      emit(
        state.copyWith(
          status: IntegrazioneStatus.error,
          error: const ApiException(
            type: ApiErrorType.unknown,
            statusCode: 200,
            message: 'User session not loaded',
          ),
        ),
      );
      return;
    }

    try {
      final pending = await _fetchMonthEndStatus();
      final data = await _repository.fetchIntegrazione(
        myId: user.id,
        lang: _lang,
      );
      emit(
        state.copyWith(
          status: IntegrazioneStatus.loaded,
          data: data,
          monthEndPending: pending,
          clearMonthEndPending: pending == null,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(status: IntegrazioneStatus.error, error: e));
    }
  }

  Future<SurveyMonthEndPending?> _fetchMonthEndStatus() async {
    try {
      return await _surveyRepository.fetchMonthEndStatus();
    } catch (_) {
      return null;
    }
  }

  /// Marks [product] as taken today, then reloads so the progress reflects it.
  ///
  /// Throws [ApiException] on failure (the backend currently returns FORBIDDEN
  /// for `user_integratori` writes) so the UI can surface it as a toast.
  Future<void> markTakenToday(IntegrazioneProduct product) async {
    final user = _userCubit.state.user;
    final kitId = state.data?.kitId;
    if (user == null || kitId == null) return;

    await _repository.markTaken(
      myId: user.id,
      productId: product.id,
      kitId: kitId,
      trackingId: product.tracking?.id,
      day: DateTime.now(),
    );
    await load();
  }

  /// Reverses [markTakenToday] — the "Preso oggi" CTA is reversible.
  Future<void> unmarkTakenToday(IntegrazioneProduct product) async {
    final kitId = state.data?.kitId;
    final trackingId = product.tracking?.id;
    if (kitId == null || trackingId == null) return;

    await _repository.unmarkTaken(
      trackingId: trackingId,
      kitId: kitId,
      day: DateTime.now(),
    );
    await load();
  }
}
