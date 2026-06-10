import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/home_data.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({HomeData? initialData}) : super(HomeState(data: initialData));

  void loadWithData(HomeData data) {
    emit(HomeState(status: HomeStatus.loaded, data: data));
  }

  Future<void> load() async {
    if (state.data != null) {
      emit(state.copyWith(status: HomeStatus.loaded));
      return;
    }
    emit(state.copyWith(status: HomeStatus.loading));
    // TODO: call repository when backend is ready
  }
}