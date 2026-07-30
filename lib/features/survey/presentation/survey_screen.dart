import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/hex_color.dart';
import '../../../l10n/app_localizations.dart';
import '../../user/presentation/cubit/user_cubit.dart';
import '../domain/entities/survey_answer.dart';
import '../domain/entities/survey_outcome.dart';
import '../domain/entities/survey_step.dart';
import 'cubit/survey_cubit.dart';
import 'survey_validation_l10n.dart';
import 'widgets/survey_answer_input.dart';
import 'widgets/survey_cta_button.dart';
import 'widgets/survey_html.dart';
import 'widgets/survey_kit_card.dart';
import 'widgets/survey_pharmacy_picker.dart';
import 'widgets/survey_result_actions.dart';
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
      listenWhen: (p, c) =>
          p.status != c.status || p.pendingAlert != c.pendingAlert,
      listener: (context, state) async {
        if (state.pendingAlert != null) {
          await _showAlertDialog(context, state.pendingAlert!);
          return;
        }

        if (state.status != SurveyStatus.completed) return;

        // The outcome is shown on the in-wizard result section (submitted on
        // the way in), so completing means the user dismissed it.
        //
        // Where to go next is the backend's call, not ours: the submit moves
        // `profile_status` on (type_survey → starter_kit), which may require a
        // further survey — the starter kit's proof of purchase. Reload the
        // session and follow the status, so finishing here cannot skip a gate.
        final user = getIt<UserCubit>();
        try {
          await user.loadSession();
        } on ApiException {
          // Keep the user moving; the gate is re-evaluated on the next launch.
        }
        if (!context.mounted) return;
        context.go(user.state.route ?? '/home');
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

/// Shows the CMS-driven confirmation dialog for an `#alert#`-marked option
/// (`alert_survey_risky_selection_modal`). Confirming resumes the wizard via
/// [SurveyCubit.confirmAlert]; dismissing (backdrop tap or "Annulla") leaves
/// the user on the current step via [SurveyCubit.dismissAlert].
Future<void> _showAlertDialog(
  BuildContext context,
  SurveyAlertModal modal,
) async {
  final cubit = context.read<SurveyCubit>();
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: modal.title?.isNotEmpty ?? false
          ? SurveyHtml(html: modal.title!, baseFontSize: 18, bold: true)
          : null,
      content: modal.content?.isNotEmpty ?? false
          ? SurveyHtml(html: modal.content!, baseFontSize: 15)
          : null,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Annulla'),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Continua'),
        ),
      ],
    ),
  );
  if (confirmed ?? false) {
    await cubit.confirmAlert();
  } else {
    cubit.dismissAlert();
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
      stepLabel: _stepLabel(section, stepNumber),
      ctaLabel: _ctaLabel(section, state),
      // A `#stop#` answer (e.g. "sei in gravidanza" → "Sì") pins the wizard on
      // this section: the CTA (CMS-labeled "Chiudi" here) stays enabled but,
      // per next(), only closes the wizard rather than submitting — going
      // back is still the only way to change the answer.
      ctaEnabled: state.canLeaveCurrentStep,
      busy: state.status == SurveyStatus.submitting,
      // A live validation failure takes precedence: it tells the user why the
      // CTA is disabled, whereas errorMessage reports a failed request.
      errorMessage:
          state.currentValidationError?.message(
            AppLocalizations.of(context)!,
          ) ??
          state.errorMessage,
      // On the first step of *this* survey instance, fall back to popping
      // the route rather than hiding the arrow outright: a chained survey
      // (e.g. "Non ho uno Starter Kit" → single_product_survey) is pushed on
      // top of a previous one, so there is a real screen to return to even
      // though this cubit's own step index is 0.
      onBack: !state.isFirstStep
          ? cubit.previous
          : (Navigator.canPop(context) ? () => context.pop() : null),
      onCta: cubit.next,
      child: _SectionBody(section: section, state: state),
    );
  }

  String _ctaLabel(SurveySection section, SurveyState state) {
    if (section.ctaLabel?.isNotEmpty ?? false) return section.ctaLabel!;
    // The last step ends this survey, but another (chained) survey may follow
    // — see `onboardingRedirectFor` — so "Fine" would be misleading; "Continua"
    // holds regardless of what comes next.
    return state.isLastStep ? 'Continua' : 'Avanti';
  }

  /// The small header caption, shown only when the CMS sets
  /// `small_notification_text` for this section — no placeholder otherwise.
  String? _stepLabel(SurveySection section, int stepNumber) {
    final note = section.smallNotificationText?.trim();
    if (note == null || note.isEmpty) return null;
    return '$stepNumber. $note';
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

    // A `#stop#` answer jumps here without submitting, so nothing depends on
    // a real outcome/submit result is safe to render — only the section's own
    // title/subtitle/content (already CMS copy for this case).
    final isResult =
        section.kind == SurveySectionKind.result && !state.blockedByStop;
    // UserCubit is a get_it singleton rather than a tree-provided bloc (there is
    // no MultiBlocProvider above the router), so read it from the locator.
    final firstName = getIt<UserCubit>().state.user?.firstName;
    final placeholders = <String, String>{
      // {{name}} appears outside result screens too (e.g. starter_kit's "{{name}}
      // sei all'inizio del tuo percorso!" info step), so it's always available.
      if (firstName != null && firstName.isNotEmpty) 'name': firstName,
      // Result screens additionally fill {{type}}/{{outcome_profile}} from the
      // submit outcome.
      if (isResult) ..._outcomePlaceholders(state.outcomeProfile),
      // The proof-of-purchase step ("Inserisci il codice a barre di:
      // "{{product}}"") appears both after a product-dropdown question
      // (single_product_survey) and on its own (starter_kit, generic kit).
      'product': ?_productName(state),
    };

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
            highlightColor: isResult
                ? colorFromHex(state.outcomeProfile?.mainColor)
                : null,
          ),
        if (section.subtitle?.isNotEmpty ?? false) ...[
          const SizedBox(height: AppSpacing.spaceMd),
          SurveyHtml(
            html: section.subtitle!,
            baseFontSize: 15,
            color: AppColors.textPrimary,
            lineHeight: 1.45,
            placeholders: placeholders,
          ),
        ],
        if (section.content?.isNotEmpty ?? false) ...[
          const SizedBox(height: AppSpacing.spaceSm),
          SurveyHtml(
            html: section.content!,
            baseFontSize: 15,
            lineHeight: 1.45,
            placeholders: placeholders,
            emphasisKeys: const {'outcome_profile'},
          ),
        ],
        // The "Hai completato il profilo!" screen (starter_kit /
        // single_product_survey) templates `{{final_asset}}` in its content —
        // not a CMS file on the section itself, but the recommended kit's
        // product image from the user's own (already assigned) biotype.
        if (section.content?.contains('{{final_asset}}') ?? false) ...[
          const SizedBox(height: AppSpacing.spaceLg),
          _FinalAssetImage(),
        ],
        if (isResult) ...[
          const SizedBox(height: AppSpacing.spaceLg),
          SurveyKitCard(outcome: state.outcomeProfile),
          const SizedBox(height: AppSpacing.spaceLg),
          SurveyResultActions(kitShopUrl: state.submitResult?.kitShopUrl),
        ],
        if (section.loadKilocalPoints && !state.blockedByStop) ...[
          const SizedBox(height: AppSpacing.spaceXl),
          SurveyPharmacyPicker(
            selected: state.selectedPharmacy,
            onSearch: cubit.searchPharmacies,
            onSelected: cubit.selectPharmacy,
          ),
        ],
        if (section.question != null && !state.blockedByStop) ...[
          const SizedBox(height: AppSpacing.spaceXl),
          _QuestionInput(
            section: section,
            question: section.question!,
            answer: answer,
            cubit: cubit,
          ),
        ],
        if (section.showSingleProductCta && !state.blockedByStop) ...[
          const SizedBox(height: AppSpacing.spaceLg),
          _NoStarterKitButton(),
        ],
      ],
    );
  }

  /// The name for `{{product}}`, shown in quotes on the proof-of-purchase step
  /// ("Inserisci il codice a barre di: "{{product}}"").
  ///
  /// `single_product_survey` asks a `show_as_dropdown` product question right
  /// before the barcode step, so the name is the label of the option the user
  /// picked. `starter_kit` has no such question — its barcode step is about a
  /// product from the user's own kit, randomly picked by the cubit
  /// ([SurveyState.kitBarcodeProduct]); this literal is only the fallback
  /// while that read is in flight or fails.
  static const _genericProductName = 'Starter Kit Kilocal';

  String? _productName(SurveyState state) {
    final survey = state.survey;
    if (survey == null) return null;
    SurveySection? dropdown;
    for (final s in survey.sections) {
      if (s.showAsDropdown) {
        dropdown = s;
        break;
      }
    }
    if (dropdown == null) {
      return state.kitBarcodeProduct?.title ?? _genericProductName;
    }

    final selectedId =
        state.answers[dropdown.id]?.selectedOptionIds.firstOrNull;
    for (final option in dropdown.question?.options ?? const <SurveyOption>[]) {
      if (option.id == selectedId) return option.text ?? _genericProductName;
    }
    return _genericProductName;
  }

  /// Builds the result-screen placeholders the CMS copy expects.
  ///
  /// The CMS `type_survey` result section uses `{{name}}`, `{{type}}` and
  /// `{{outcome_profile}}` — names that match neither the submit response's own
  /// keys nor each other, so they are mapped explicitly. `{{type}}` →
  /// "Tipo 2 - Mela" and `{{outcome_profile}}` → the personalized biotype copy,
  /// both from the hydrated [biotype]. `{{name}}` is handled by the caller for
  /// every section, not just result screens.
  ///
  /// Any placeholder left unmapped is stripped by [SurveyHtml], so a partial
  /// outcome degrades to plain copy instead of leaking `{{…}}`.
  Map<String, String> _outcomePlaceholders(SurveyOutcome? biotype) {
    final rawOutcome = state.submitResult?.outcome;
    return {
      // Scalar top-level keys first, so other surveys' result copy keeps
      // resolving against its own placeholders — the explicit mappings below
      // take precedence on collision.
      if (rawOutcome != null)
        for (final entry in rawOutcome.entries)
          if (entry.value is String || entry.value is num)
            entry.key: '${entry.value}',
      if (biotype?.typeDisplay != null) 'type': biotype!.typeDisplay!,
      if (biotype?.description != null)
        'outcome_profile': biotype!.description!,
    };
  }
}

/// The illustration for the `{{final_asset}}` placeholder on the "Hai
/// completato il profilo!" screen: the same local celebration asset
/// (`assets/goal.png`, a clapping-hands 3D render) already used for the
/// Traguardi tab's hero card (`DiaryHeroCard`/`diary_screen.dart`). The CMS
/// section carries no image field — this placeholder is filled locally, not
/// from any backend data.
class _FinalAssetImage extends StatelessWidget {
  const _FinalAssetImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 148,
            height: 148,
            decoration: const BoxDecoration(
              color: AppColors.neutralWhite,
              shape: BoxShape.circle,
            ),
          ),
          Image.asset(
            'assets/goal.png',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

/// The `show_single_product_cta` escape hatch on the starter kit's
/// proof-of-purchase step: a user who bought a single product rather than the
/// full Starter Kit follows `single_product_survey` instead, which asks which
/// product and then its own barcode.
class _NoStarterKitButton extends StatelessWidget {
  const _NoStarterKitButton();

  @override
  Widget build(BuildContext context) {
    return SurveyCtaButton.outlined(
      label: AppLocalizations.of(context)!.surveyNoStarterKit,
      // push (not go): keeps the starter-kit survey on the stack underneath,
      // so the back arrow below has something to return to instead of
      // leaving this step with no way back.
      onPressed: () =>
          context.push('/survey?internalName=single_product_survey'),
    );
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
