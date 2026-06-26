import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/entities/momenti_data.dart';
import '../../domain/momenti_repository.dart';

part 'momenti_state.dart';

class MomentiCubit extends Cubit<MomentiState> {
  MomentiCubit({required MomentiRepository momentiRepository})
    : _momentiRepository = momentiRepository,
      super(const MomentiState());

  final MomentiRepository _momentiRepository;

  Future<void> load({String? id}) async {
    emit(state.copyWith(status: MomentiStatus.loading, error: null));

    try {
      final moment = await _momentiRepository.fetchMoment(id: id);
      emit(state.copyWith(status: MomentiStatus.loaded, data: moment));
    } on ApiException catch (e) {
      emit(state.copyWith(status: MomentiStatus.error, error: e));
    }
  }
}
