import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../domain/entities/survey_answer.dart';
import '../domain/entities/survey_step.dart';
import 'cubit/survey_cubit.dart';
import 'widgets/survey_answer_input.dart';
import 'widgets/survey_html.dart';
import 'widgets/survey_kit_card.dart';
import 'widgets/survey_pharmacy_picker.dart';
import 'widgets/survey_scaffold.dart';

/// Entry point for the CMS-driven survey wizard. Pass the CMS `internalName`
/// (e.g. `type_survey`, `starter_kit`) via the route.
class SurveyScreen extends StatelessWidget {
  const SurveyScreen({super.key, required this.internalName});

  final String internalName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SurveyCubit>()..start(internalName),
      child: const _SurveyView(),
    );
  }
}

class _SurveyView extends StatelessWidget {
  const _SurveyView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SurveyCubit, SurveyState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        if (state.status == SurveyStatus.completed) {
          // TODO(backend): route to the outcome/result destination once the
          // `outcome` / kit_shop_url contract is confirmed. For now, land home.
          context.go('/home');
        }
      },
      builder: (context, state) {
        switch (state.status) {
          case SurveyStatus.initial:
          case SurveyStatus.loading:
            return const Scaffold(
              backgroundColor: AppColors.surface,
              body: Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
            );
          case SurveyStatus.failure:
            return _FailureView(message: state.errorMessage);
          case SurveyStatus.inProgress:
          case SurveyStatus.submitting:
          case SurveyStatus.completed:
            return _StepView(state: state);
        }
      },
    );
  }
}

class _StepView extends StatelessWidget {
  const _StepView({required this.state});

  final SurveyState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SurveyCubit>();
    final section = state.currentSection;
    if (section == null) {
      return const Scaffold(backgroundColor: AppColors.surface);
    }

    final stepNumber = state.currentIndex + 1;

    return SurveyScaffold(
      totalSteps: state.visibleSections.length,
      currentIndex: state.currentIndex,
      stepLabel: '$stepNumber. ${_stepLabel(section)}',
      ctaLabel: _ctaLabel(section, state),
      ctaEnabled: _canProceed(section, state),
      busy: state.status == SurveyStatus.submitting,
      errorMessage: state.errorMessage,
      // No back arrow on the first step.
      onBack: state.isFirstStep ? null : cubit.previous,
      onCta: cubit.next,
      child: _SectionBody(section: section, state: state),
    );
  }

  String _ctaLabel(SurveySection section, SurveyState state) {
    if (section.ctaLabel?.isNotEmpty ?? false) return section.ctaLabel!;
    return state.isLastStep ? 'Fine' : 'Avanti';
  }

  /// The small header caption. Uses the CMS `small_notification_text` when set,
  /// otherwise a neutral placeholder (as in the design).
  String _stepLabel(SurveySection section) {
    final note = section.smallNotificationText;
    return (note != null && note.trim().isNotEmpty)
        ? note.trim()
        : 'Scritta solo per step corrente';
  }

  /// Blocks the CTA until a required question is answered / a pharmacy chosen.
  bool _canProceed(SurveySection section, SurveyState state) {
    if (section.loadKilocalPoints) return state.selectedPharmacy != null;
    final question = section.question;
    if (question == null || !question.required) return true;
    final answer = state.currentAnswer;
    return answer != null && !answer.isEmpty;
  }
}

/// Renders the body for a section based on its [SurveySectionKind] and, for
/// questions, the answer type.
class _SectionBody extends StatelessWidget {
  const _SectionBody({required this.section, required this.state});

  final SurveySection section;
  final SurveyState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SurveyCubit>();
    final answer = state.currentAnswer;

    final isResult = section.kind == SurveySectionKind.result;
    // Result screens fill {{name}}/{{type}}/{{product}}/{{outcome_profile}} from
    // the submit outcome. TODO(backend): confirm the exact outcome keys once a
    // real submit response is available (see wiki/survey.md).
    final placeholders = isResult
        ? _outcomePlaceholders(state.submitResult)
        : const <String, String>{};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (section.title?.isNotEmpty ?? false)
          SurveyHtml(
            html: section.title!,
            baseFontSize: 26,
            color: Colors.black,
            bold: true,
            lineHeight: 1.2,
            placeholders: placeholders,
            highlightKeys: const {'type'},
          ),
        if (section.subtitle?.isNotEmpty ?? false) ...[
          const SizedBox(height: AppSpacing.spaceMd),
          SurveyHtml(
            html: section.subtitle!,
            baseFontSize: 15,
            color: AppColors.textPrimary,
            placeholders: placeholders,
          ),
        ],
        if (section.content?.isNotEmpty ?? false) ...[
          const SizedBox(height: AppSpacing.spaceSm),
          SurveyHtml(
            html: section.content!,
            baseFontSize: 15,
            placeholders: placeholders,
          ),
        ],
        if (isResult) ...[
          const SizedBox(height: AppSpacing.spaceLg),
          SurveyKitCard(outcome: state.submitResult?.outcome),
        ],
        if (section.loadKilocalPoints) ...[
          const SizedBox(height: AppSpacing.spaceXl),
          SurveyPharmacyPicker(
            selected: state.selectedPharmacy,
            onSearch: cubit.searchPharmacies,
            onSelected: cubit.selectPharmacy,
          ),
        ],
        if (section.question != null) ...[
          const SizedBox(height: AppSpacing.spaceXl),
          _QuestionInput(
            section: section,
            question: section.question!,
            answer: answer,
            cubit: cubit,
          ),
        ],
      ],
    );
  }

  /// Flattens the submit outcome into string placeholders for result-screen
  /// templating (`{{name}}`, `{{type}}`, …). Values are best-effort until the
  /// outcome contract is confirmed with backend.
  Map<String, String> _outcomePlaceholders(SurveySubmitResult? result) {
    final outcome = result?.outcome;
    if (outcome == null) return const {};
    return {
      for (final entry in outcome.entries)
        if (entry.value is String || entry.value is num)
          entry.key: '${entry.value}',
    };
  }
}

class _QuestionInput extends StatelessWidget {
  const _QuestionInput({
    required this.section,
    required this.question,
    required this.answer,
    required this.cubit,
  });

  final SurveySection section;
  final SurveyQuestion question;
  final SurveyAnswer? answer;
  final SurveyCubit cubit;

  @override
  Widget build(BuildContext context) {
    final selectedIds = answer?.selectedOptionIds ?? const <String>[];

    switch (question.type) {
      case SurveyAnswerType.radio:
        if (section.showAsDropdown) {
          return SurveyOptionsDropdown(
            options: question.options,
            selectedId: selectedIds.isNotEmpty ? selectedIds.first : null,
            hint: question.placeholder,
            onSelected: cubit.selectRadio,
          );
        }
        return SurveyOptionsList(
          key: ValueKey('survey-options-${section.id}'),
          options: question.options,
          selectedIds: selectedIds,
          otherValue: answer?.otherValue,
          onOtherChanged: cubit.setOtherValue,
          otherFieldKey: ValueKey('survey-other-${section.id}'),
          onToggle: cubit.selectRadio,
        );
      case SurveyAnswerType.checkbox:
        return SurveyOptionsList(
          key: ValueKey('survey-options-${section.id}'),
          options: question.options,
          selectedIds: selectedIds,
          otherValue: answer?.otherValue,
          onOtherChanged: cubit.setOtherValue,
          otherFieldKey: ValueKey('survey-other-${section.id}'),
          onToggle: cubit.toggleCheckbox,
        );
      case SurveyAnswerType.scale:
        return SurveyScaleInput(
          from: question.scaleFrom ?? 0,
          to: question.scaleTo ?? 10,
          value: answer?.scaleValue,
          initialLabel: question.scaleInitialLabel,
          finalLabel: question.scaleFinalLabel,
          onChanged: cubit.setScale,
        );
      case SurveyAnswerType.input:
      case SurveyAnswerType.unknown:
        if (question.inputType == SurveyInputType.date) {
          return Padding(
            padding: const EdgeInsets.only(top: AppSpacing.spaceXl),
            child: SurveyDateField(
              // Keyed by section so consecutive text/date steps don't reuse the
              // previous step's field state (which leaked the prior answer).
              key: ValueKey('survey-date-${section.id}'),
              value: answer?.textValue,
              hint: question.placeholder,
              onChanged: cubit.setText,
            ),
          );
        }
        // The design places the free-text answer lower, with a big underline.
        return Padding(
          padding: const EdgeInsets.only(top: AppSpacing.spaceXl),
          child: SurveyTextField(
            // Keyed by section so consecutive text steps don't reuse the
            // previous step's field state (which leaked the prior answer).
            key: ValueKey('survey-text-${section.id}'),
            large: true,
            hint: question.placeholder?.isNotEmpty ?? false
                ? question.placeholder
                : 'Inserisci la risposta',
            value: answer?.textValue,
            onChanged: cubit.setText,

            keyboardType: question.inputType == SurveyInputType.number
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
            inputFormatters: question.inputType == SurveyInputType.number
                ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))]
                : null,
          ),
        );
    }
  }
}

class _FailureView extends StatelessWidget {
  const _FailureView({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenGutter),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.accent,
              ),
              const SizedBox(height: AppSpacing.spaceMd),
              Text(
                message ?? 'Si è verificato un errore',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
