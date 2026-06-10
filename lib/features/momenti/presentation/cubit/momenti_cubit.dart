import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'momenti_state.dart';

class MeccanicaItem {
  const MeccanicaItem({required this.day, required this.description});

  final String day;
  final String description;
}

class MomentiData {
  const MomentiData({
    required this.title,
    required this.body,
    required this.heroImageUrl,
    required this.meccanica,
  });

  final String title;
  final String body;
  final String heroImageUrl;
  final List<MeccanicaItem> meccanica;
}

class MomentiCubit extends Cubit<MomentiState> {
  MomentiCubit() : super(const MomentiState());

  Future<void> load() async {
    emit(state.copyWith(status: MomentiStatus.loading));
    await Future<void>.delayed(const Duration(milliseconds: 600));
    emit(
      state.copyWith(
        status: MomentiStatus.loaded,
        data: const MomentiData(
          title: 'Sfida 7 Giorni',
          body: 'Partecipa alla nostra sfida settimanale per migliorare il tuo benessere. Ogni giorno una nuova attività da completare per costruire sane abitudini.',
          heroImageUrl: 'https://placehold.co/600x300/e51e4d/ffffff?text=Momenti',
          meccanica: [
            MeccanicaItem(day: 'Giorno 1', description: 'Bevi 2 litri d\'acqua durante la giornata.'),
            MeccanicaItem(day: 'Giorno 2', description: 'Fai una passeggiata di 30 minuti all\'aperto.'),
            MeccanicaItem(day: 'Giorno 3', description: 'Prepara un pasto sano e bilanciato.'),
            MeccanicaItem(day: 'Giorno 4', description: 'Meditazione guidata di 10 minuti.'),
            MeccanicaItem(day: 'Giorno 5', description: 'Screentime ridotto di 1 ora.'),
            MeccanicaItem(day: 'Giorno 6', description: 'Allenamento cardio di 20 minuti.'),
            MeccanicaItem(day: 'Giorno 7', description: 'Riflessione e pianificazione della settimana.'),
          ],
        ),
      ),
    );
  }
}