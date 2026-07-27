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
  String get onboardingStart => 'Iniziamo';

  @override
  String get onboardingSkip => 'Salta';

  @override
  String get loginTitle => 'Accedi';

  @override
  String get loginSubtitle =>
      'Ogni giorno un passo più vicino alla tua ricomposizione.';

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
      'Per scoprire il tuo tipo e il percorso su misura per te compila il form e inizia il test.';

  @override
  String get registerFirstName => 'Nome';

  @override
  String get registerLastName => 'Cognome';

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
  String get registerBottomPrompt => 'Hai già un account?';

  @override
  String get registerBottomLink => 'Accedi';

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
  String get forgotPasswordTitle => 'Recupera password';

  @override
  String get forgotPasswordSubtitle =>
      'Inserisci l\'email del tuo account. Ti invieremo un link per reimpostare la password.';

  @override
  String get forgotPasswordButton => 'Invia link';

  @override
  String get forgotPasswordBackPrompt => 'Ti sei ricordato la password?';

  @override
  String get forgotPasswordBackLink => 'Accedi';

  @override
  String get forgotPasswordSuccessTitle => 'Controlla la tua email';

  @override
  String get forgotPasswordSuccessDescription =>
      'Se l\'indirizzo è associato a un account, riceverai un link per reimpostare la password.';

  @override
  String get forgotPasswordErrorMissingEmail => 'Inserisci la tua email.';

  @override
  String get forgotPasswordErrorBadRequest =>
      'Email non valida. Controlla e riprova.';

  @override
  String get forgotPasswordErrorNetwork =>
      'Connessione assente. Riprova più tardi.';

  @override
  String get forgotPasswordErrorServer =>
      'Errore del server. Riprova più tardi.';

  @override
  String get forgotPasswordErrorGeneric =>
      'Si è verificato un errore. Riprova.';

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
  String get homeStartPath => 'Inizia il percorso';

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
  String get pathLockedTitle => 'Contenuto bloccato';

  @override
  String get pathLockedBody =>
      'Questo contenuto non è disponibile per il tuo piano corrente. Acquista il tuo starter kit per sbloccare il programma completo';

  @override
  String get pathLockedUnderstood => 'Ho capito';

  @override
  String get pathLockedBoughtKit => 'Ho acquistato lo Starter kit';

  @override
  String get pathTimeframeLockedTitle => 'Mese bloccato';

  @override
  String get pathTimeframeLockedBody =>
      'Per sbloccare questo mese devi prima completare tutte le attività del mese precedente.';

  @override
  String get pathMonthCompletedTitle => 'Complimenti!';

  @override
  String get pathMonthCompletedBody =>
      'Hai completato tutte le attività di questo mese.';

  @override
  String get pathMonthCompletedCta => 'Vedi le statistiche';

  @override
  String get pathUnlockTitle => 'Sblocca il programma';

  @override
  String get pathUnlockInstructions =>
      'Inserisci il codice a barre che trovi sulla confezione del prodotto Kilocal che hai acquistato. Il codice è composto da 1 lettera iniziale + 9 numeri.';

  @override
  String get pathUnlockCodeHint => 'Inserisci codice prova d\'acquisto…';

  @override
  String get pathUnlockSubmit => 'Inserisci';

  @override
  String get pathUnlockInvalidCode =>
      'Questo codice non corrisponde a nessun prodotto Kilocal. Controllalo e riprova.';

  @override
  String get pathUnlockSuccess => 'Programma sbloccato!';

  @override
  String get diaryTitle => 'Diario delle attività';

  @override
  String get benefitsTitle => 'Benefit';

  @override
  String get profileTitle => 'Il tuo Profilo';

  @override
  String get profileMyTypeSection => 'Il mio Tipo';

  @override
  String get profileMyTypeValue => 'Tipo 4 - Pera';

  @override
  String get profileTypeUnknown => 'Il mio Tipo';

  @override
  String get profileTypeCharacteristics => 'Le tue caratteristiche';

  @override
  String get profileTypeDiscoverMore => 'Scopri di più';

  @override
  String profileTypeStartingPoint(String type) {
    return '$type - Il tuo punto di partenza';
  }

  @override
  String get profileTypePathToFeelBest => 'Il percorso per stare al meglio';

  @override
  String get profileTypePointTitleFallback => 'Punto del corpo';

  @override
  String get profileTypePointBodyFallback => 'Contenuto in arrivo.';

  @override
  String get profileTypeIntegrationSheetTitle => 'Integrazione';

  @override
  String get profileTypeIntegrationSheetHeadline =>
      'Il tuo percorso Kilocal non è solo alimentazione e movimento!';

  @override
  String get profileTypeIntegrationSheetBody =>
      'Il kit di integratori è pensato per accompagnarti passo dopo passo, riattivando l\'energia del corpo e potenziando i risultati del tuo percorso.';

  @override
  String get profileTypeIntegrationSheetCta => 'Vedi sezione dedicata';

  @override
  String get profileTypeProductsSection => 'Informazioni sui prodotti';

  @override
  String get profileTypeMyKit => 'Il mio Kit';

  @override
  String get profileTypeSupplements => 'Integrazioni e prodotti';

  @override
  String profileKitTitle(String type) {
    return 'Kit $type';
  }

  @override
  String get profileKitBuy => 'Acquista';

  @override
  String get profileKitEmpty => 'Nessun prodotto disponibile.';

  @override
  String get profileCategorySection => 'Nome categoria sezioni';

  @override
  String get profilePersonalData => 'I miei dati personali';

  @override
  String get profileMyAccount => 'Il mio account';

  @override
  String get profileSaved => 'Modifiche salvate';

  @override
  String get profileAvatarChange => 'Modifica foto profilo';

  @override
  String get profileAvatarFromCamera => 'Scatta una foto';

  @override
  String get profileAvatarFromGallery => 'Scegli dalla galleria';

  @override
  String get profileAvatarUpdated => 'Foto profilo aggiornata';

  @override
  String get profileAvatarError => 'Impossibile aggiornare la foto profilo';

  @override
  String get profileChangePassword => 'Cambia password';

  @override
  String get profileChangePasswordHint =>
      'Scegli una nuova password per il tuo account.';

  @override
  String get profileNewPassword => 'Nuova password';

  @override
  String get profileConfirmPassword => 'Conferma nuova password';

  @override
  String get profileChangePasswordSubmit => 'Aggiorna password';

  @override
  String get profilePasswordUpdated => 'Password aggiornata';

  @override
  String get profilePasswordError => 'Impossibile aggiornare la password';

  @override
  String profilePasswordTooShort(int count) {
    return 'La password deve avere almeno $count caratteri';
  }

  @override
  String get profilePasswordMismatch => 'Le due password non coincidono';

  @override
  String get profileFoodPreferences => 'Preferenze alimentari';

  @override
  String get profileFoodPreferencesEdit => 'Aggiungi o modifica';

  @override
  String get profileFoodPreferencesEmpty => 'Nessuna selezione';

  @override
  String get profileNotificationsSection => 'Notifiche';

  @override
  String get profilePushNotifications => 'Notifiche push';

  @override
  String get profilePushNotificationsStatus => 'Attive';

  @override
  String get profileSupportSection => 'Assistenza';

  @override
  String get profileTutorial => 'Tutorial come usare l\'app';

  @override
  String get profileContactSupport => 'Contatta l\'assistenza';

  @override
  String get profileContactSupportNoMailApp =>
      'Nessuna app email configurata su questo dispositivo. Scrivi a info@kilocalprogram.it';

  @override
  String get profileLogout => 'Esci';

  @override
  String get profileLogoutConfirmTitle => 'Esci dall\'account';

  @override
  String get profileLogoutConfirmBody =>
      'Sei sicuro di voler uscire dal tuo account?';

  @override
  String get profileLogoutConfirmCancel => 'Annulla';

  @override
  String get profileLogoutConfirmAction => 'Esci';

  @override
  String get profileAppVersionSection => 'App';

  @override
  String get profileAppVersion => 'Versione app';

  @override
  String profileAppVersionValue(String version) {
    return 'Versione $version';
  }

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
  String get surveyFindPharmacy => 'Trova una Farmacia Kilocal Point';

  @override
  String get surveyGoToShop => 'Vai allo shop';

  @override
  String get surveyEnterProofOfPurchase => 'Inserisci prova d\'acquisto';

  @override
  String get surveyNoStarterKit => 'Non ho uno Starter Kit';

  @override
  String get surveyErrorNotANumber => 'Inserisci un numero valido';

  @override
  String get surveyErrorNotAnInteger => 'Inserisci un numero intero';

  @override
  String get surveyErrorTooSmall => 'Il valore inserito è troppo basso';

  @override
  String get surveyErrorTooLarge => 'Il valore inserito è troppo alto';

  @override
  String get surveyErrorNotADate => 'Inserisci una data valida';

  @override
  String get surveyErrorDateTooLate => 'Devi avere almeno 18 anni';

  @override
  String get surveyErrorDateTooEarly => 'Inserisci una data valida';

  @override
  String get surveyErrorBmiTooLow =>
      'Il peso inserito non è compatibile con la tua altezza';

  @override
  String get surveyErrorInvalidZipCode => 'Inserisci un CAP valido (5 cifre)';

  @override
  String get surveyErrorInvalidPhone =>
      'Inserisci un numero di telefono valido';

  @override
  String get surveyErrorInvalidBarcode =>
      'Codice a barre non riconosciuto. Controlla il codice sulla confezione del tuo Starter Kit.';

  @override
  String get surveyBarcodeChecking => 'Verifica del codice in corso…';

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
  String get benefitClaimReward => 'Ottieni il premio';

  @override
  String get benefitClaimRewardError => 'Impossibile aprire il link del premio';

  @override
  String benefitVisitSite(String partner) {
    return 'Visita il sito di $partner';
  }

  @override
  String get benefitCouponCopied => 'Codice sconto copiato';

  @override
  String get benefitsEmpty => 'Nessun benefit disponibile';

  @override
  String get momentiTitle => 'Momenti';

  @override
  String get momentiEmpty => 'Nessun momento disponibile';

  @override
  String get momentiInfoTitle => 'Informazioni';

  @override
  String get momentiInfoTooltip => 'Informazioni sul momento';

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
  String get integrationCurrentPhase => 'Fase attuale';

  @override
  String get integrationNotStarted => 'Non ancora iniziata';

  @override
  String get integrationPhasesTitle => 'Il tuo piano';

  @override
  String get integrationEmpty => 'Nessun piano di integrazione disponibile.';

  @override
  String integrationProductDuration(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days giorni',
      one: '1 giorno',
    );
    return '$_temp0';
  }

  @override
  String integrationProductQuantity(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count al giorno',
      one: '1 al giorno',
    );
    return '$_temp0';
  }

  @override
  String integrationPhaseLabel(int number) {
    return 'Fase $number';
  }

  @override
  String integrationCompletePhaseFirst(int number) {
    return 'Completa prima la fase $number';
  }

  @override
  String integrationPhaseTitle(int number) {
    return 'Integrazione Fase $number';
  }

  @override
  String integrationMonitoringWeeks(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: 'Monitoraggio $weeks settimane',
      one: 'Monitoraggio 1 settimana',
    );
    return '$_temp0';
  }

  @override
  String integrationMonitoringDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Monitoraggio $days giorni',
      one: 'Monitoraggio 1 giorno',
    );
    return '$_temp0';
  }

  @override
  String get integrationMarkTaken => 'Segna integrato come preso';

  @override
  String get integrationTakenToday => 'Preso oggi';

  @override
  String get integrationMarkTakenError =>
      'Impossibile registrare l\'assunzione. Riprova più tardi.';

  @override
  String get integrationMarkedTaken => 'Assunzione registrata';

  @override
  String get integrationInstructionsTitle => 'Istruzioni sull\'uso';

  @override
  String get integrationStartDate => 'Data inizio:';

  @override
  String get integrationExpectedEndDate => 'Data fine prevista:';

  @override
  String get integrationEnableReminder => 'Attiva promemoria';

  @override
  String integrationReminderActiveLabel(String label) {
    return 'Promemoria attivo: $label';
  }

  @override
  String get integrationReminderSnooze2hShort => 'posticipa di 2 ore';

  @override
  String get integrationReminderSnooze4hShort => 'posticipa di 4 ore';

  @override
  String get integrationReminderSnooze8hShort => 'posticipa di 8 ore';

  @override
  String get integrationReminderSnooze1dShort => 'posticipa di 1 giorno';

  @override
  String get integrationReminderEnabled => 'Promemoria attivato';

  @override
  String get integrationReminderError =>
      'Impossibile attivare il promemoria. Controlla i permessi delle notifiche.';

  @override
  String get integrationReminderAddTitle => 'Aggiungi promemoria';

  @override
  String get integrationReminderEditDeleteTitle =>
      'Modifica o elimina promemoria';

  @override
  String get integrationReminderEditTitle => 'Modifica promemoria';

  @override
  String get integrationReminderSelectTime => 'Seleziona orario';

  @override
  String get integrationReminderConfirm => 'Conferma';

  @override
  String get integrationReminderSave => 'Salva';

  @override
  String get integrationReminderCancel => 'Annulla';

  @override
  String get integrationReminderEdit => 'Modifica';

  @override
  String get integrationReminderDelete => 'Elimina';

  @override
  String get integrationReminderDeleteConfirm =>
      'Sicuro di voler eliminare questo promemoria?';

  @override
  String get integrationReminderDeleted => 'Promemoria eliminato';

  @override
  String integrationReminderMessage(String product) {
    return 'Assumere il prodotto \"$product\". Questo messaggio è generato automaticamente.';
  }

  @override
  String integrationReminderSnoozedLabel(String label) {
    return 'Posticipata di $label';
  }

  @override
  String get integrationReminderSnooze2h => 'Posticipa di 2 ore';

  @override
  String get integrationReminderSnooze4h => 'Posticipa di 4 ore';

  @override
  String get integrationReminderSnooze8h => 'Posticipa di 8 ore';

  @override
  String get integrationReminderSnooze1d => 'Posticipa di 1 giorno';

  @override
  String get diaryTabHistory => 'Cronologia';

  @override
  String get diaryTabGoals => 'Traguardi';

  @override
  String get diaryHistoryEmpty => 'Nessuna attività ancora registrata.';

  @override
  String get diaryGoalsEmpty => 'Non hai ancora nessun traguardo.';

  @override
  String get diaryGoalPersonal => 'Personale';

  @override
  String get diaryGoalKilocal => 'Kilocal';

  @override
  String get diaryGoalCompleted => 'Raggiunto';

  @override
  String get diaryFilterAll => 'Tutti i traguardi';

  @override
  String get diaryFilterPersonal => 'Traguardi personali';

  @override
  String get diaryFilterKilocal => 'Traguardi Kilocal';

  @override
  String get diaryFilterCompleted => 'Completati';

  @override
  String get diaryGoalCreateTitle => 'Nuovo traguardo';

  @override
  String get diaryGoalEditTitle => 'Modifica traguardo';

  @override
  String get diaryGoalContentHint => 'Descrivi il tuo traguardo';

  @override
  String get diaryGoalCategory => 'Categoria';

  @override
  String get diaryGoalPickDate => 'Aggiungi una data';

  @override
  String get diaryGoalSave => 'Salva';

  @override
  String get diaryGoalComplete => 'Completa traguardo';

  @override
  String get diaryGoalMarkIncomplete => 'Segna come non raggiunto';

  @override
  String get diaryGoalDelete => 'Elimina traguardo';

  @override
  String get diaryGoalDeleteConfirmTitle => 'Eliminare il traguardo?';

  @override
  String get diaryGoalDeleteConfirmBody =>
      'Questa azione non può essere annullata.';

  @override
  String get diaryGoalDeleteConfirmCancel => 'Annulla';

  @override
  String get diaryGoalDeleteConfirmAction => 'Elimina';

  @override
  String get diaryActivityDetailTitle => 'Dettagli Attività';

  @override
  String diaryActivityCategory(String category) {
    return 'Categoria: $category';
  }

  @override
  String diaryActivityPlannedOn(String date) {
    return 'Completamento previsto: $date';
  }

  @override
  String diaryActivityToComplete(String date) {
    return 'Da completare: $date';
  }

  @override
  String get diaryActivityCompleteError =>
      'Impossibile completare l\'attività. Riprova.';

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
  String pathStepVideoDuration(String duration) {
    return '$duration min';
  }

  @override
  String get commonClose => 'Chiudi';

  @override
  String get pathActivitiesTitle => 'Attività';

  @override
  String pathActivitiesTotal(int count) {
    return '$count totali';
  }

  @override
  String get pathTimerSetTitle => 'Imposta Timer';

  @override
  String get pathTimerHours => 'Ore';

  @override
  String get pathTimerMinutes => 'Minuti';

  @override
  String get pathTimerSeconds => 'Secondi';

  @override
  String get pathTimerStart => 'Avvia timer';

  @override
  String pathTimerPill(String time) {
    return 'Timer: $time';
  }

  @override
  String get pathTimerStop => 'interrompi';

  @override
  String get pathTimerPause => 'Pausa';

  @override
  String get pathTimerResume => 'Riprendi';

  @override
  String get pathAreaProgressLabel => 'Il tuo percorso';

  @override
  String get pathMaterialsTitle => 'Materiali extra';

  @override
  String get pathMaterialsSubtitle => 'Risorse utili per il tuo percorso';

  @override
  String get pathMaterialsEmpty => 'Nessun materiale disponibile';

  @override
  String get pathMaterialsFilterToWatch => 'Da vedere';

  @override
  String get pathMaterialsFilterWatched => 'Visti';

  @override
  String get pathMaterialMarkCompleted => 'Segna come completato';

  @override
  String get pathMaterialCompleted => 'Completato';

  @override
  String get pathMaterialDownloadError =>
      'Impossibile aprire il file. Riprova.';

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

  @override
  String get strumentiTitle => 'Strumenti';

  @override
  String get strumentiLaunch => 'Avvia strumento';

  @override
  String get strumentiPromemoria => 'Promemoria';

  @override
  String get strumentiTimer => 'Timer';

  @override
  String get strumentiGlossario => 'Glossario';

  @override
  String get strumentiGallery => 'Gallery';

  @override
  String get strumentiComingSoon => 'Questo strumento sarà presto disponibile.';

  @override
  String get glossarioSearch => 'Cerca';

  @override
  String get glossarioSearchHint => 'Parola chiave';

  @override
  String get glossarioResults => 'Risultati corrispondenti';

  @override
  String get glossarioEmpty => 'Nessun risultato per questa ricerca.';

  @override
  String get glossarioLoadError => 'Impossibile caricare il glossario.';

  @override
  String get galleryPhotosTitle => 'Le mie foto';

  @override
  String get galleryUploadTitle => 'Carica immagine';

  @override
  String get galleryUploadInfo =>
      'Usa il bottone per caricare il contenuto del tuo dispositivo';

  @override
  String get galleryUpload => 'Carica';

  @override
  String get galleryTakePhoto => 'Scatta foto';

  @override
  String get galleryRetakePhoto => 'Scatta di nuovo';

  @override
  String get galleryConfirmUpload => 'Conferma e carica';

  @override
  String get galleryUploadError => 'Impossibile caricare la foto. Riprova.';

  @override
  String get galleryDeleteError => 'Impossibile eliminare la foto. Riprova.';

  @override
  String get galleryLoadError => 'Impossibile caricare le foto.';

  @override
  String get galleryEmpty => 'Non hai ancora caricato nessuna foto.';

  @override
  String get galleryToolBlocked =>
      'Questo strumento non è al momento disponibile.';

  @override
  String get galleryDelete => 'Elimina';

  @override
  String get galleryCancel => 'Annulla';

  @override
  String get gallerySplitTitle => 'Split image';

  @override
  String get gallerySave => 'Salva';

  @override
  String get galleryShare => 'Condividi';

  @override
  String get gallerySaved => 'Immagine salvata';

  @override
  String get gallerySaveError => 'Impossibile salvare l\'immagine.';

  @override
  String get promemoriaViewList => 'Lista';

  @override
  String get promemoriaViewCalendar => 'Calendario';

  @override
  String get promemoriaEmpty => 'Nessun promemoria per questo mese.';

  @override
  String get promemoriaLoadError => 'Impossibile caricare i promemoria.';

  @override
  String get promemoriaAddTitle => 'Aggiungi promemoria';

  @override
  String get promemoriaMessageLabel => 'Messaggio';

  @override
  String get promemoriaMessageHint => 'Inserisci qui il testo del promemoria';

  @override
  String get promemoriaDateLabel => 'Data';

  @override
  String get promemoriaTimeLabel => 'Ora';

  @override
  String get promemoriaSelectDate => 'Seleziona data';

  @override
  String get promemoriaSelectTime => 'Seleziona orario';

  @override
  String get promemoriaConfirm => 'Conferma';

  @override
  String get promemoriaSave => 'Salva promemoria';

  @override
  String get promemoriaEditTitle => 'Modifica Promemoria';

  @override
  String get promemoriaEdit => 'Modifica';

  @override
  String get promemoriaSaveShort => 'Salva';

  @override
  String get promemoriaDelete => 'Elimina';

  @override
  String get promemoriaDeleteTitle => 'Elimina promemoria';

  @override
  String get promemoriaCancel => 'Annulla';

  @override
  String get promemoriaDeleteConfirm =>
      'Sicuro di voler eliminare il promemoria?';
}
