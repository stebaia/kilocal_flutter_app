import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kilocal_flutter_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/survey/survey_free_step.dart';
import '../../../core/widgets/survey/survey_info_step.dart';
import '../../../core/widgets/survey/survey_intermezzo_step.dart';
import '../../../core/widgets/survey/survey_preset_step.dart';
import '../../../core/widgets/survey/survey_proof_step.dart';
import '../../survey/domain/entities/survey_step.dart';
import 'cubit/survey_cubit.dart';

class SurveyScreen extends StatelessWidget {
  const SurveyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SurveyCubit()..start(),
      child: const _SurveyView(),
    );
  }
}

class _SurveyView extends StatelessWidget {
  const _SurveyView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<SurveyCubit, SurveyState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == SurveyStatus.completed) {
          context.go('/home');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: BackButton(
            onPressed: () {
              final cubit = context.read<SurveyCubit>();
              if (cubit.state.isFirstStep) {
                context.pop();
              } else {
                cubit.previous();
              }
            },
          ),
        ),
        extendBodyBehindAppBar: true,
        body: BlocBuilder<SurveyCubit, SurveyState>(
          builder: (context, state) {
            final step = state.currentStepData;
            if (step == null) return const SizedBox.shrink();

            switch (step.type) {
              case SurveyStepType.intermezzo:
                return SurveyIntermezzoStep(title: step.title);
              case SurveyStepType.kitResult:
              case SurveyStepType.platformIntro:
              case SurveyStepType.info:
                return SurveyInfoStep(
                  title: step.title,
                  body: step.body,
                  buttonLabel: state.isLastStep ? l10n.surveyStart : l10n.surveyNext,
                  onNext: () => context.read<SurveyCubit>().next(),
                );
              case SurveyStepType.preset:
                return SurveyPresetStep(
                  title: step.title,
                  body: step.body,
                  choices: step.choices!,
                  selected: state.answers[state.currentStep] as String?,
                  onSelect: (c) => context.read<SurveyCubit>().selectChoice(c),
                  onNext: () => context.read<SurveyCubit>().next(),
                  nextLabel: l10n.surveyNext,
                );
              case SurveyStepType.free:
                return SurveyFreeStep(
                  title: step.title,
                  body: step.body,
                  hint: step.hint,
                  value: state.answers[state.currentStep] as String?,
                  onChanged: (t) => context.read<SurveyCubit>().setTextAnswer(t),
                  onNext: () => context.read<SurveyCubit>().next(),
                  nextLabel: l10n.surveyNext,
                );
              case SurveyStepType.proofOfPurchase:
                return SurveyProofStep(
                  title: step.title,
                  body: step.body,
                  hint: step.hint,
                  value: state.answers[state.currentStep] as String?,
                  onChanged: (t) => context.read<SurveyCubit>().setProofOfPurchase(t),
                  onNext: () => context.read<SurveyCubit>().next(),
                  verifyLabel: l10n.surveyVerify,
                );
            }
          },
        ),
      ),
    );
  }
}