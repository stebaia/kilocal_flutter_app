import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/brand_gradient_background.dart';
import '../../../core/widgets/survey/survey_choice_card.dart';
import '../../../core/widgets/survey/survey_text_input.dart';
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
                return _IntermezzoStep(step: step);
              case SurveyStepType.kitResult:
              case SurveyStepType.platformIntro:
              case SurveyStepType.info:
                return _InfoStep(step: step, isLast: state.isLastStep, onNext: () => context.read<SurveyCubit>().next());
              case SurveyStepType.preset:
                return _PresetStep(
                  step: step,
                  selected: state.answers[state.currentStep] as String?,
                  onSelect: (c) => context.read<SurveyCubit>().selectChoice(c),
                  onNext: () => context.read<SurveyCubit>().next(),
                );
              case SurveyStepType.free:
                return _FreeStep(
                  step: step,
                  value: state.answers[state.currentStep] as String?,
                  onChanged: (t) => context.read<SurveyCubit>().setTextAnswer(t),
                  onNext: () => context.read<SurveyCubit>().next(),
                );
              case SurveyStepType.proofOfPurchase:
                return _ProofStep(
                  step: step,
                  value: state.answers[state.currentStep] as String?,
                  onChanged: (t) => context.read<SurveyCubit>().setProofOfPurchase(t),
                  onNext: () => context.read<SurveyCubit>().next(),
                );
            }
          },
        ),
      ),
    );
  }
}

class _PresetStep extends StatelessWidget {
  const _PresetStep({required this.step, this.selected, required this.onSelect, required this.onNext});

  final SurveyStep step;
  final String? selected;
  final ValueChanged<String> onSelect;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return _StepLayout(
      title: step.title,
      body: step.body,
      child: Column(
        children: [
          ...step.choices!.map((choice) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.spaceSm),
              child: SurveyChoiceCard(
                label: choice,
                selected: selected == choice,
                onTap: () => onSelect(choice),
              ),
            );
          }),
          const SizedBox(height: AppSpacing.spaceLg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selected != null ? onNext : null,
              child: const Text('Avanti'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FreeStep extends StatelessWidget {
  const _FreeStep({required this.step, this.value, required this.onChanged, required this.onNext});

  final SurveyStep step;
  final String? value;
  final ValueChanged<String> onChanged;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return _StepLayout(
      title: step.title,
      body: step.body,
      child: Column(
        children: [
          SurveyTextInput(
            hint: step.hint,
            maxLines: 4,
            onChanged: onChanged,
          ),
          const SizedBox(height: AppSpacing.spaceLg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: value != null && value!.trim().isNotEmpty ? onNext : null,
              child: const Text('Avanti'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProofStep extends StatelessWidget {
  const _ProofStep({required this.step, this.value, required this.onChanged, required this.onNext});

  final SurveyStep step;
  final String? value;
  final ValueChanged<String> onChanged;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return _StepLayout(
      title: step.title,
      body: step.body,
      child: Column(
        children: [
          SurveyTextInput(
            hint: step.hint,
            onChanged: onChanged,
          ),
          const SizedBox(height: AppSpacing.spaceLg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: value != null && value!.trim().isNotEmpty ? onNext : null,
              child: const Text('Verifica'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoStep extends StatelessWidget {
  const _InfoStep({required this.step, required this.isLast, required this.onNext});

  final SurveyStep step;
  final bool isLast;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return _StepLayout(
      title: step.title,
      body: step.body,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onNext,
          child: Text(isLast ? 'Inizia' : 'Avanti'),
        ),
      ),
    );
  }
}

class _IntermezzoStep extends StatelessWidget {
  const _IntermezzoStep({required this.step});

  final SurveyStep step;

  @override
  Widget build(BuildContext context) {
    return BrandGradientBackground(
      showTopGlow: true,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenGutter),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FlutterLogo(size: 160),
              const SizedBox(height: AppSpacing.spaceLg),
              Text(
                step.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutralWhite,
                ),
              ),
              const SizedBox(height: AppSpacing.spaceMd),
              const CircularProgressIndicator(color: AppColors.neutralWhite),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepLayout extends StatelessWidget {
  const _StepLayout({required this.title, this.body, required this.child});

  final String title;
  final String? body;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        top: kToolbarHeight + AppSpacing.spaceLg,
        left: AppSpacing.screenGutter,
        right: AppSpacing.screenGutter,
        bottom: AppSpacing.spaceLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.textTheme.headlineLarge),
          if (body != null) ...[
            const SizedBox(height: AppSpacing.spaceMd),
            Text(body!, style: AppTypography.textTheme.bodyMedium),
          ],
          const SizedBox(height: AppSpacing.spaceLg),
          child,
        ],
      ),
    );
  }
}