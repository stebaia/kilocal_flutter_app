import 'package:flutter/material.dart';

import 'survey_step_layout.dart';

/// Informational step: title, body copy, and a single action button.
class SurveyInfoStep extends StatelessWidget {
  const SurveyInfoStep({
    super.key,
    required this.title,
    this.body,
    required this.buttonLabel,
    required this.onNext,
  });

  final String title;
  final String? body;
  final String buttonLabel;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SurveyStepLayout(
      title: title,
      body: body,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(onPressed: onNext, child: Text(buttonLabel)),
      ),
    );
  }
}
