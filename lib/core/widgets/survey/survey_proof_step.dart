import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import 'survey_step_layout.dart';
import 'survey_text_input.dart';

/// Proof-of-purchase step: single-line text input
/// with a verify action button.
class SurveyProofStep extends StatelessWidget {
  const SurveyProofStep({
    super.key,
    required this.title,
    this.body,
    this.hint,
    this.value,
    required this.onChanged,
    required this.onNext,
    required this.verifyLabel,
  });

  final String title;
  final String? body;
  final String? hint;
  final String? value;
  final ValueChanged<String> onChanged;
  final VoidCallback onNext;
  final String verifyLabel;

  @override
  Widget build(BuildContext context) {
    return SurveyStepLayout(
      title: title,
      body: body,
      child: Column(
        children: [
          SurveyTextInput(hint: hint, onChanged: onChanged),
          const SizedBox(height: AppSpacing.spaceLg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: value != null && value!.trim().isNotEmpty
                  ? onNext
                  : null,
              child: Text(verifyLabel),
            ),
          ),
        ],
      ),
    );
  }
}
