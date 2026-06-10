import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import 'survey_step_layout.dart';
import 'survey_text_input.dart';

/// Free-answer step: displays a multi-line text input
/// with a Next button at the bottom.
class SurveyFreeStep extends StatelessWidget {
  const SurveyFreeStep({
    super.key,
    required this.title,
    this.body,
    this.hint,
    this.value,
    required this.onChanged,
    required this.onNext,
    required this.nextLabel,
  });

  final String title;
  final String? body;
  final String? hint;
  final String? value;
  final ValueChanged<String> onChanged;
  final VoidCallback onNext;
  final String nextLabel;

  @override
  Widget build(BuildContext context) {
    return SurveyStepLayout(
      title: title,
      body: body,
      child: Column(
        children: [
          SurveyTextInput(
            hint: hint,
            maxLines: 4,
            onChanged: onChanged,
          ),
          const SizedBox(height: AppSpacing.spaceLg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: value != null && value!.trim().isNotEmpty ? onNext : null,
              child: Text(nextLabel),
            ),
          ),
        ],
      ),
    );
  }
}