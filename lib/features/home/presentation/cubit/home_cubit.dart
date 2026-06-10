import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/home_data.dart';

part 'home_state.dart';

/// Cubit that loads home screen data.
/// Currently uses mock data until the backend contract is available.
class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  Future<void> load() async {
    emit(state.copyWith(status: HomeStatus.loading));
    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 800));
    emit(
      state.copyWith(
        status: HomeStatus.loaded,
        data: _mockData,
      ),
    );
  }

  static const HomeData _mockData = HomeData(
    userName: 'Management',
    overallProgress: 0.80,
    quickCards: [
      QuickCard(title: 'Mese 1', subtitle: 'Fase base', icon: '📅'),
      QuickCard(title: 'Aree', subtitle: '4 attive', icon: '🎯'),
    ],
    heroItems: [
      HeroItem(
        title: 'Scopri il nuovo programma',
        subtitle: 'Nutrizione personalizzata',
        imageUrl: 'https://placehold.co/600x300/e51e4d/ffffff?text=Hero+1',
      ),
      HeroItem(
        title: 'Allenamento consigliato',
        subtitle: '3 esercizi per oggi',
        imageUrl: 'https://placehold.co/600x300/c9143c/ffffff?text=Hero+2',
      ),
    ],
  );
}