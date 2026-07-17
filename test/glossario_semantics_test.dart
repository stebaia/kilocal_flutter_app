import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kilocal_flutter_app/app/di.dart';
import 'package:kilocal_flutter_app/core/theme/theme.dart';
import 'package:kilocal_flutter_app/features/strumenti/glossario/domain/entities/glossary_entry.dart';
import 'package:kilocal_flutter_app/features/strumenti/glossario/domain/glossario_repository.dart';
import 'package:kilocal_flutter_app/features/strumenti/glossario/presentation/cubit/glossario_cubit.dart';
import 'package:kilocal_flutter_app/features/strumenti/glossario/presentation/glossario_screen.dart';
import 'package:kilocal_flutter_app/l10n/app_localizations.dart';

/// Reproduces the `!semantics.parentDataDirty` assertion the screen throws on
/// device: semantics enabled, real screen, fake data.
class _FakeRepo implements GlossarioRepository {
  @override
  Future<GlossaryContent> getContent() async => const GlossaryContent(
    title: 'Glossario',
    searchPlaceholder: 'Inserisci parola chiave',
  );

  @override
  Future<List<GlossaryEntry>> getEntries() async => [
    for (var i = 0; i < 20; i++)
      GlossaryEntry(
        id: '$i',
        title: 'Voce ${String.fromCharCode(65 + i % 5)}$i',
        content: '<p>Definizione della voce $i</p>',
      ),
  ];
}

void main() {
  setUp(() async {
    await getIt.reset();
    getIt.registerLazySingleton<GlossarioRepository>(() => _FakeRepo());
    getIt.registerFactory<GlossarioCubit>(
      () => GlossarioCubit(repository: getIt<GlossarioRepository>()),
    );
  });

  testWidgets('glossario lays out and builds a clean semantics tree',
      (tester) async {
    final semantics = tester.ensureSemantics();

    // The app theme is load-bearing: it gives every button an
    // infinite-width minimumSize, which is what broke the search Row.
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('it'), Locale('en')],
        locale: const Locale('it'),
        home: const GlossarioScreen(),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // Expand a card too: the Html definition only builds when open. The card
    // sits below the fold (the letter grid fills half the viewport), so
    // scroll it into existence first — SliverList builds lazily.
    final scrollable = find
        .descendant(
          of: find.byType(CustomScrollView),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      find.text('Voce A0'),
      200,
      scrollable: scrollable,
    );
    await tester.tap(find.text('Voce A0'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    semantics.dispose();
  });
}
