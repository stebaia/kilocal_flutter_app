// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Kilocal';

  @override
  String get splashLoading => 'Caricamento in corso...';

  @override
  String get onboardingTitle1 => 'Benvenuto in Kilocal';

  @override
  String get onboardingBody1 =>
      'Inizia il tuo percorso personalizzato di benessere con noi.';

  @override
  String get onboardingTitle2 => 'Segui il tuo percorso';

  @override
  String get onboardingBody2 =>
      'Allenamento, alimentazione, benessere e integrazione in un unico posto.';

  @override
  String get onboardingTitle3 => 'Traccia i tuoi progressi';

  @override
  String get onboardingBody3 =>
      'Monitora i tuoi risultati e raggiungi i tuoi obiettivi.';

  @override
  String get onboardingNext => 'Avanti';

  @override
  String get onboardingStart => 'Inizia';

  @override
  String get loginTitle => 'Accedi';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginButton => 'Accedi';

  @override
  String get loginForgotPassword => 'Password dimenticata?';

  @override
  String get loginNoAccount => 'Non hai un account?';

  @override
  String get loginSignUp => 'Registrati';

  @override
  String homeGreeting(String name) {
    return 'Ciao $name';
  }

  @override
  String get homeProgress => 'Progressi complessivi';

  @override
  String get homeQuickLinks => 'Link rapidi';

  @override
  String get homeHeroTitle => 'Per te';

  @override
  String get tabHome => 'Home';

  @override
  String get tabPath => 'Percorso';

  @override
  String get tabDiary => 'Diario';

  @override
  String get tabBenefits => 'Benefit';

  @override
  String get tabProfile => 'Profilo';

  @override
  String get pathTitle => 'Il tuo percorso';

  @override
  String get pathOverallProgress => 'Progressi complessivi';

  @override
  String get diaryTitle => 'Diario';

  @override
  String get benefitsTitle => 'Benefit';

  @override
  String get profileTitle => 'Profilo';

  @override
  String get statisticsTitle => 'Statistiche';

  @override
  String get statisticsMonth => 'Mese corrente';

  @override
  String get notificationsTitle => 'Notifiche';

  @override
  String get errorGeneric => 'Qualcosa è andato storto. Riprova.';

  @override
  String get retry => 'Riprova';
}
