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
  String get loginSubtitle =>
      'Lorem ipsum dolor sit amet consectetur. Ullamcorper quis lacus.';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginButton => 'Accedi';

  @override
  String get loginForgotPrompt => 'Hai dimenticato la password?';

  @override
  String get loginForgotLink => 'Recuperala qui';

  @override
  String get loginNoAccount => 'Non hai un account?';

  @override
  String get loginSignUp => 'Registrati';

  @override
  String get registerTitle => 'Registrati';

  @override
  String get registerSubtitle =>
      'Lorem ipsum dolor sit amet consectetur. Ullamcorper quis lacus.';

  @override
  String get registerFullName => 'Nome e Cognome';

  @override
  String get registerEmail => 'Indirizzo e-mail';

  @override
  String get registerPassword => 'Password';

  @override
  String get registerPasswordConfirm => 'Conferma password';

  @override
  String get registerTermsPrefix => 'Registrandoti accetti i';

  @override
  String get registerTermsLink => 'termini e condizioni';

  @override
  String get registerButton => 'Registrati';

  @override
  String get registerBottomPrompt => 'Non sei iscritto?';

  @override
  String get registerBottomLink => 'Registrati subito';

  @override
  String get registerSuccessTitle => 'Registrazione completata';

  @override
  String get registerSuccessDescription =>
      'Ora puoi accedere con le tue credenziali.';

  @override
  String get errorTitle => 'Errore';

  @override
  String get registerErrorMissingFields =>
      'Compila tutti i campi obbligatori e accetta i termini.';

  @override
  String get registerErrorPasswordMismatch => 'Le password non coincidono.';

  @override
  String get registerErrorConflict => 'Email già registrata.';

  @override
  String get registerErrorBadRequest =>
      'Dati non validi. Controlla i campi inseriti.';

  @override
  String get registerErrorNetwork => 'Connessione assente. Riprova più tardi.';

  @override
  String get registerErrorServer => 'Errore del server. Riprova più tardi.';

  @override
  String get registerErrorGeneric => 'Si è verificato un errore. Riprova.';

  @override
  String get loginErrorMissingFields => 'Inserisci email e password.';

  @override
  String get loginErrorUnauthorized => 'Email o password non valide.';

  @override
  String get loginErrorBadRequest =>
      'Dati non validi. Controlla email e password.';

  @override
  String get loginErrorNetwork => 'Connessione assente. Riprova più tardi.';

  @override
  String get loginErrorServer => 'Errore del server. Riprova più tardi.';

  @override
  String get loginErrorGeneric => 'Si è verificato un errore. Riprova.';

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
  String get homeContinuePath => 'Continua il percorso';

  @override
  String get homeSeeStatistics => 'Vedi statistiche';

  @override
  String get homeMoments => 'Momenti';

  @override
  String get homeBenefits => 'Benefit';

  @override
  String get homePathCardTitle => 'Titolo contenuto da continuare lorem ipsuim';

  @override
  String get homeMonthStatsDescription =>
      'Lorem ipsum dolor sit amet consectetur. Facilisi varius.';

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
  String get pathActivitiesCompleted => 'Attività complete';

  @override
  String get diaryTitle => 'Diario';

  @override
  String get benefitsTitle => 'Benefit';

  @override
  String get profileTitle => 'Profilo';

  @override
  String get profileLogout => 'Esci';

  @override
  String get logoutConfirmationTitle => 'Vuoi uscire?';

  @override
  String get logoutConfirmationMessage =>
      'Sei sicuro di voler effettuare il logout?';

  @override
  String get logoutConfirm => 'Esci';

  @override
  String get logoutCancel => 'Annulla';

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

  @override
  String get surveyNext => 'Avanti';

  @override
  String get surveyVerify => 'Verifica';

  @override
  String get surveyStart => 'Inizia';

  @override
  String get notificationsEmpty => 'Nessuna notifica';

  @override
  String get notificationArchive => 'Archivia notifica';

  @override
  String get notificationsFilterAll => 'Tutte';

  @override
  String get notificationsFilterUnread => 'Non lette';

  @override
  String get notificationsFilterRead => 'Lette';

  @override
  String get notificationsFilterArchived => 'Archiviate';

  @override
  String get benefitDetails => 'Dettagli';

  @override
  String get benefitsPrimaryPartners => 'Partner Primari';

  @override
  String get benefitsSecondaryPartners => 'Partner Secondari';

  @override
  String get benefitViewDetails => 'Visualizza dettagli';

  @override
  String get benefitsEmpty => 'Nessun benefit disponibile';

  @override
  String get diaryCompleted => 'Completato';

  @override
  String get diaryPending => 'In attesa';

  @override
  String get areaTraining => 'Allenamento';

  @override
  String get areaNutrition => 'Alimentazione';

  @override
  String get areaWellbeing => 'Benessere';

  @override
  String get areaIntegration => 'Integrazione';

  @override
  String get month1 => 'Mese 1';

  @override
  String get phase1 => 'Fase 1';

  @override
  String activitiesCount(int completed, int total) {
    return '$completed/$total attività';
  }

  @override
  String pathCompletedPercent(int percent) {
    return 'completato al $percent%';
  }

  @override
  String get pathStepContentTitle => 'Attività';

  @override
  String get pathStepComplete => 'Completa attività';

  @override
  String get pathStepLocked => 'Bloccato';

  @override
  String get pathStepCurrent => 'Corrente';

  @override
  String get pathStepCompleted => 'Completato';

  @override
  String get pathStepStarted => 'Iniziato';

  @override
  String get pathAreaProgressLabel => 'Il tuo percorso';

  @override
  String get pathMaterialsTitle => 'Materiali extra';

  @override
  String get pathMaterialsSubtitle => 'Risorse utili per il tuo percorso';

  @override
  String pathTimeframeStepsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count attività',
      one: '1 attività',
    );
    return '$_temp0';
  }

  @override
  String get pathTimeframeLocked => 'Bloccato';

  @override
  String get pathTimeframeCurrent => 'In corso';

  @override
  String get pathAreaLocked => 'Questo percorso non è ancora disponibile.';
}
