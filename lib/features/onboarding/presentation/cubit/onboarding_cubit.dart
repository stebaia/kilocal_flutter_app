import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(const OnboardingState());

  void nextPage() {
    if (state.currentPage < state.totalPages - 1) {
      emit(state.copyWith(currentPage: state.currentPage + 1));
    }
  }

  void setPage(int page) {
    emit(state.copyWith(currentPage: page));
  }
}