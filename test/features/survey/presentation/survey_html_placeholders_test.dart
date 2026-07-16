import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kilocal_flutter_app/features/survey/presentation/widgets/survey_html.dart';

/// Renders the real `type_survey` result copy (CMS section id 9, fetched from
/// staging) through [SurveyHtml] to prove the placeholders actually resolve.
///
/// Regression: `{{name}}` / `{{type}}` / `{{outcome_profile}}` used to be
/// resolved against the submit response's own top-level keys. They never
/// matched, so the cleanup regex stripped them and the title collapsed to
/// "Ottimo , risulti essere un" with no type text at all.
void main() {
  // Verbatim from the CMS (staging, it-IT).
  const resultTitle = '<p>Ottimo {{name}}, risulti essere un {{type}}</p>';
  const resultContent =
      '<p>{{outcome_profile}}<br>Attenzione: le informazioni e i consigli che '
      'proponiamo sono generali e come tali vanno considerati.</p>';

  Future<void> pump(WidgetTester tester, Widget child) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );
  }

  testWidgets('fills name and type in the result title', (tester) async {
    await pump(
      tester,
      const SurveyHtml(
        html: resultTitle,
        placeholders: {'name': 'Mario', 'type': 'Tipo 3 - Peperone'},
        highlightKeys: {'type'},
      ),
    );

    expect(
      find.textContaining('Ottimo Mario, risulti essere un Tipo 3 - Peperone'),
      findsOneWidget,
    );
  });

  testWidgets('fills the personalized type copy in the content', (
    tester,
  ) async {
    await pump(
      tester,
      const SurveyHtml(
        html: resultContent,
        placeholders: {
          'outcome_profile': 'Tendi ad avere un accumulo omogeneo',
        },
        emphasisKeys: {'outcome_profile'},
      ),
    );

    expect(
      find.textContaining('Tendi ad avere un accumulo omogeneo'),
      findsOneWidget,
    );
    // The disclaimer still follows the personalized copy.
    expect(find.textContaining('Attenzione:'), findsOneWidget);
  });

  testWidgets('strips unfilled placeholders rather than leaking {{…}}', (
    tester,
  ) async {
    await pump(tester, const SurveyHtml(html: resultTitle));

    expect(find.textContaining('{{'), findsNothing);
    expect(find.textContaining('Ottimo'), findsOneWidget);
  });
}
