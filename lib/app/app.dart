import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kilocal_flutter_app/l10n/app_localizations.dart';
import '../core/theme/theme.dart';
import '../features/path/presentation/widgets/path_timer_pill.dart';
import 'di.dart';
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
      // Persistent workout-timer pill, shown above whatever route is on
      // screen so it survives navigation regardless of which screen (path
      // step or strumenti) started the timer. Lifted above the bottom nav
      // bar (AppScaffold in router.dart: a 48-tall badge plus spaceSm
      // padding on each side) so it floats above it instead of sitting
      // underneath/behind it on the tabbed routes.
      builder: (context, child) {
        const navBarContentHeight = 48 + 2 * AppSpacing.spaceSm;

        return Stack(
          children: [
            ?child,
            Positioned(
              left: 0,
              right: 0,
              bottom: navBarContentHeight,
              child: SafeArea(
                top: false,
                child: PathTimerPill(controller: getIt<PathTimerController>()),
              ),
            ),
          ],
        );
      },
    );
  }
}
