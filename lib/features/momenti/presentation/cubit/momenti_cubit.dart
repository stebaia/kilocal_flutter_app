import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/momenti_data.dart';

part 'momenti_state.dart';

class MomentiCubit extends Cubit<MomentiState> {
  MomentiCubit({MomentiData? initialData}) : super(MomentiState(data: initialData));

  Future<void> load() async {
    if (state.data != null) {
      emit(state.copyWith(status: MomentiStatus.loaded));
      return;
    }
    emit(state.copyWith(status: MomentiStatus.loading));
    // TODO: call repository when backend is ready
  }
}