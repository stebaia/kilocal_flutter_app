import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/network/api_exception.dart';
import '../../../user/presentation/cubit/user_cubit.dart';
import '../../domain/entities/home_data.dart';
import '../../domain/home_repository.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required HomeRepository homeRepository,
    required UserCubit userCubit,
  }) : _homeRepository = homeRepository,
       _userCubit = userCubit,
       super(const HomeState());

  final HomeRepository _homeRepository;
  final UserCubit _userCubit;

  void loadWithData(HomeData data) {
    emit(HomeState(status: HomeStatus.loaded, data: data));
  }

  Future<void> load() async {
    emit(state.copyWith(status: HomeStatus.loading));

    final user = _userCubit.state.user;
    final details = _userCubit.state.details;

    if (user == null) {
      emit(
        state.copyWith(
          status: HomeStatus.error,
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
      final data = await _homeRepository.fetchHome(
        myId: user.id,
        currentMonth: details?.activeTimeframe ?? 1,
        userName: user.firstName ?? user.email ?? '',
      );
      emit(state.copyWith(status: HomeStatus.loaded, data: data, error: null));
    } on ApiException catch (e) {
      emit(state.copyWith(status: HomeStatus.error, error: e));
    }
  }
}
