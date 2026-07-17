import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app/di.dart';
import 'core/theme/theme.dart';
import 'features/auth/domain/auth_repository.dart';
import 'features/strumenti/glossario/presentation/glossario_screen.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';

/// Temporary harness: real GlossarioScreen against staging. Delete after use.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  configureDependencies();
  await getIt<AuthRepository>().login(
    email: 'mobile.test.active@thefullproject.it',
    password: 'MobileTest-Active2026!',
  );
  debugPrint('VERIFY: login OK');
  runApp(const _Harness());
}

class _Harness extends StatelessWidget {
  const _Harness();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('it'), Locale('en')],
      locale: const Locale('it'),
      theme: AppTheme.light,
      home: const GlossarioScreen(),
    );
  }
}
