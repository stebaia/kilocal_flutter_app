import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kilocal_flutter_app/features/survey/presentation/widgets/survey_cta_button.dart';

/// Renders both CTA variants.
///
/// Regression: the outlined variant passed both `shape` and `borderRadius` to
/// [Material], which asserts they are mutually exclusive — the result screen's
/// kit buttons crashed with "shape != null && borderRadius != null is not
/// true".
void main() {
  Future<void> pump(WidgetTester tester, Widget child) {
    return tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
  }

  testWidgets('renders the outlined variant', (tester) async {
    await pump(
      tester,
      SurveyCtaButton.outlined(label: 'Vai allo shop', onPressed: () {}),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Vai allo shop'), findsOneWidget);
  });

  testWidgets('renders the filled variant', (tester) async {
    await pump(
      tester,
      SurveyCtaButton(label: "Inserisci prova d'acquisto", onPressed: () {}),
    );

    expect(tester.takeException(), isNull);
    expect(find.text("Inserisci prova d'acquisto"), findsOneWidget);
  });

  testWidgets('renders a disabled outlined button', (tester) async {
    await pump(
      tester,
      const SurveyCtaButton.outlined(label: 'Vai allo shop', onPressed: null),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('renders the filled variant while busy', (tester) async {
    await pump(
      tester,
      SurveyCtaButton(label: 'Fine', onPressed: () {}, busy: true),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
