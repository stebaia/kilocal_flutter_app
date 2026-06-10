import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kilocal_flutter_app/l10n/app_localizations.dart';
import '../core/theme/theme.dart';
import 'router.dart';

class KilocalApp extends StatelessWidget {
  const KilocalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Kilocal',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('it'), Locale('en')],
      locale: const Locale('it'),
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}