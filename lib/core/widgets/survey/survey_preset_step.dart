import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import 'survey_choice_card.dart';
import 'survey_step_layout.dart';

/// Preset-answer step: displays a list of tappable choices
/// with a Next button at the bottom.
class SurveyPresetStep extends StatelessWidget {
  const SurveyPresetStep({
    super.key,
    required this.title,
    this.body,
    required this.choices,
    this.selected,
    required this.onSelect,
    required this.onNext,
    required this.nextLabel,
  });

  final String title;
  final String? body;
  final List<String> choices;
  final String? selected;
  final ValueChanged<String> onSelect;
  final VoidCallback onNext;
  final String nextLabel;

  @override
  Widget build(BuildContext context) {
    return SurveyStepLayout(
      title: title,
      body: body,
      child: Column(
        children: [
          ...choices.map((choice) {
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
              child: Text(nextLabel),
            ),
          ),
        ],
      ),
    );
  }
}
