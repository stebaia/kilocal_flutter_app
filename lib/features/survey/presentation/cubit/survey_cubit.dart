import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'survey_state.dart';

enum SurveyStepType { preset, free, info, kitResult, intermezzo, proofOfPurchase, platformIntro }

class SurveyStep {
  const SurveyStep({
    required this.type,
    required this.title,
    this.body,
    this.choices,
    this.hint,
  });

  final SurveyStepType type;
  final String title;
  final String? body;
  final List<String>? choices;
  final String? hint;
}

class SurveyCubit extends Cubit<SurveyState> {
  SurveyCubit() : super(const SurveyState());

  static const List<SurveyStep> _steps = [
    SurveyStep(
      type: SurveyStepType.preset,
      title: 'Qual è il tuo obiettivo principale?',
      choices: ['Perdere peso', 'Aumentare massa muscolare', 'Migliorare il benessere'],
    ),
    SurveyStep(
      type: SurveyStepType.free,
      title: 'Descrivi la tua routine quotidiana',
      hint: 'Es. lavoro sedentario, attività sportiva 2 volte a settimana...',
    ),
    SurveyStep(
      type: SurveyStepType.info,
      title: 'Informazioni utili',
      body: 'Il nostro programma si basa su un approccio scientifico alla nutrizione e all\'allenamento.',
    ),
    SurveyStep(
      type: SurveyStepType.intermezzo,
      title: 'Stiamo calcolando il tuo percorso ideale',
    ),
    SurveyStep(
      type: SurveyStepType.kitResult,
      title: 'Il tuo kit consigliato',
      body: 'Kit Bilanciato — Ideale per chi cerca un miglioramento generale del benessere.',
    ),
    SurveyStep(
      type: SurveyStepType.proofOfPurchase,
      title: 'Inserisci il codice prova d\'acquisto',
      hint: 'Es. KLK-2026-XXXX',
    ),
    SurveyStep(
      type: SurveyStepType.preset,
      title: 'Che tipo di alimentazione segui di solito?',
      choices: ['Onnivora', 'Vegetariana', 'Vegana', 'Pescetariana'],
    ),
    SurveyStep(
      type: SurveyStepType.platformIntro,
      title: 'Benvenuto sulla piattaforma',
      body: 'Hai completato il survey. Ora puoi iniziare il tuo percorso personalizzato.',
    ),
  ];

  void start() {
    emit(
      state.copyWith(
        status: SurveyStatus.inProgress,
        steps: _steps,
        currentStep: 0,
        answers: {},
      ),
    );
  }

  void selectChoice(String choice) {
    final current = state.currentStep;
    final updated = Map<int, dynamic>.from(state.answers)..[current] = choice;
    emit(state.copyWith(answers: updated));
  }

  void setTextAnswer(String text) {
    final current = state.currentStep;
    final updated = Map<int, dynamic>.from(state.answers)..[current] = text;
    emit(state.copyWith(answers: updated));
  }

  void setProofOfPurchase(String code) {
    final current = state.currentStep;
    final updated = Map<int, dynamic>.from(state.answers)..[current] = code;
    emit(state.copyWith(answers: updated));
  }

  void next() {
    if (state.currentStep < state.steps.length - 1) {
      emit(state.copyWith(currentStep: state.currentStep + 1));
    } else {
      emit(state.copyWith(status: SurveyStatus.completed));
    }
  }

  void previous() {
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }
}