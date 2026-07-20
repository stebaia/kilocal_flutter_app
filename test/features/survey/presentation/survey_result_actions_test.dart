import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kilocal_flutter_app/features/survey/presentation/widgets/survey_result_actions.dart';
import 'package:kilocal_flutter_app/l10n/app_localizations.dart';

/// Renders the result screen's kit actions as the screen builds them.
///
/// Regression: the outlined "Vai allo shop" button crashed the whole result
/// screen with Material's "shape != null && borderRadius != null" assertion.
/// Testing the button in isolation is not enough — this drives the real call
/// site.
void main() {
  Future<void> pump(WidgetTester tester, Widget child) {
    return tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('it')],
        locale: const Locale('it'),
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );
  }

  testWidgets('renders the shop action', (tester) async {
    await pump(
      tester,
      const SurveyResultActions(kitShopUrl: 'https://shop.kilocal.it/kit/3'),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Vai allo shop'), findsOneWidget);
  });

  testWidgets('never offers a proof-of-purchase shortcut', (tester) async {
    await pump(
      tester,
      const SurveyResultActions(kitShopUrl: 'https://shop.kilocal.it/kit/3'),
    );

    // The proof of purchase belongs to the starter_kit survey. A button here
    // sat next to "Fine" looking mandatory while being optional, and opened the
    // restricted-access sheet, whose PATCH jumps to `active` and would skip
    // that survey altogether.
    expect(find.text("Inserisci prova d'acquisto"), findsNothing);
  });

  testWidgets('omits the shop action when there is no url', (tester) async {
    await pump(tester, const SurveyResultActions());

    expect(tester.takeException(), isNull);
    expect(find.text('Vai allo shop'), findsNothing);
  });

  testWidgets('omits the shop action when the url is unusable', (tester) async {
    await pump(tester, const SurveyResultActions(kitShopUrl: 'not-a-url'));

    expect(tester.takeException(), isNull);
    expect(find.text('Vai allo shop'), findsNothing);
  });

  testWidgets('renders the pharmacy finder once it has a url', (tester) async {
    await pump(
      tester,
      const SurveyResultActions(
        kitShopUrl: 'https://shop.kilocal.it/kit/3',
        pharmacyFinderUrl: 'https://kilocal.it/punti-vendita',
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Trova una Farmacia Kilocal Point'), findsOneWidget);
  });
}
