import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
  ];

  /// App name shown in the app bar and tasks
  ///
  /// In en, this message translates to:
  /// **'Kilocal'**
  String get appTitle;

  /// Text shown while the app is loading on splash
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get splashLoading;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Kilocal'**
  String get onboardingTitle1;

  /// No description provided for @onboardingBody1.
  ///
  /// In en, this message translates to:
  /// **'Start your personalized wellness journey with us.'**
  String get onboardingBody1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Follow your path'**
  String get onboardingTitle2;

  /// No description provided for @onboardingBody2.
  ///
  /// In en, this message translates to:
  /// **'Training, nutrition, wellbeing and integration in one place.'**
  String get onboardingBody2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Track your progress'**
  String get onboardingTitle3;

  /// No description provided for @onboardingBody3.
  ///
  /// In en, this message translates to:
  /// **'Monitor your results and achieve your goals.'**
  String get onboardingBody3;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get onboardingStart;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Lorem ipsum dolor sit amet consectetur. Ullamcorper quis lacus.'**
  String get loginSubtitle;

  /// No description provided for @loginEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmail;

  /// No description provided for @loginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginButton;

  /// No description provided for @loginForgotPrompt.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get loginForgotPrompt;

  /// No description provided for @loginForgotLink.
  ///
  /// In en, this message translates to:
  /// **'Recover it here'**
  String get loginForgotLink;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get loginNoAccount;

  /// No description provided for @loginSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get loginSignUp;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Lorem ipsum dolor sit amet consectetur. Ullamcorper quis lacus.'**
  String get registerSubtitle;

  /// No description provided for @registerFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get registerFullName;

  /// No description provided for @registerEmail.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get registerEmail;

  /// No description provided for @registerPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get registerPassword;

  /// No description provided for @registerPasswordConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get registerPasswordConfirm;

  /// No description provided for @registerTermsPrefix.
  ///
  /// In en, this message translates to:
  /// **'By signing up you accept the'**
  String get registerTermsPrefix;

  /// No description provided for @registerTermsLink.
  ///
  /// In en, this message translates to:
  /// **'terms and conditions'**
  String get registerTermsLink;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get registerButton;

  /// No description provided for @registerBottomPrompt.
  ///
  /// In en, this message translates to:
  /// **'Not registered?'**
  String get registerBottomPrompt;

  /// No description provided for @registerBottomLink.
  ///
  /// In en, this message translates to:
  /// **'Sign up now'**
  String get registerBottomLink;

  /// No description provided for @registerSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Registration completed'**
  String get registerSuccessTitle;

  /// No description provided for @registerSuccessDescription.
  ///
  /// In en, this message translates to:
  /// **'You can now log in with your credentials.'**
  String get registerSuccessDescription;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// No description provided for @registerErrorMissingFields.
  ///
  /// In en, this message translates to:
  /// **'Fill in all required fields and accept the terms.'**
  String get registerErrorMissingFields;

  /// No description provided for @registerErrorPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get registerErrorPasswordMismatch;

  /// No description provided for @registerErrorConflict.
  ///
  /// In en, this message translates to:
  /// **'Email already registered.'**
  String get registerErrorConflict;

  /// No description provided for @registerErrorBadRequest.
  ///
  /// In en, this message translates to:
  /// **'Invalid data. Please check the entered fields.'**
  String get registerErrorBadRequest;

  /// No description provided for @registerErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No connection. Please try again later.'**
  String get registerErrorNetwork;

  /// No description provided for @registerErrorServer.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get registerErrorServer;

  /// No description provided for @registerErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get registerErrorGeneric;

  /// No description provided for @loginErrorMissingFields.
  ///
  /// In en, this message translates to:
  /// **'Enter email and password.'**
  String get loginErrorMissingFields;

  /// No description provided for @loginErrorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password.'**
  String get loginErrorUnauthorized;

  /// No description provided for @loginErrorBadRequest.
  ///
  /// In en, this message translates to:
  /// **'Invalid data. Please check email and password.'**
  String get loginErrorBadRequest;

  /// No description provided for @loginErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No connection. Please try again later.'**
  String get loginErrorNetwork;

  /// No description provided for @loginErrorServer.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get loginErrorServer;

  /// No description provided for @loginErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get loginErrorGeneric;

  /// Greeting on the home screen
  ///
  /// In en, this message translates to:
  /// **'Hello {name}'**
  String homeGreeting(String name);

  /// No description provided for @homeProgress.
  ///
  /// In en, this message translates to:
  /// **'Overall progress'**
  String get homeProgress;

  /// No description provided for @homeQuickLinks.
  ///
  /// In en, this message translates to:
  /// **'Quick links'**
  String get homeQuickLinks;

  /// No description provided for @homeHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'For you'**
  String get homeHeroTitle;

  /// No description provided for @homeContinuePath.
  ///
  /// In en, this message translates to:
  /// **'Continue the path'**
  String get homeContinuePath;

  /// No description provided for @homeSeeStatistics.
  ///
  /// In en, this message translates to:
  /// **'See statistics'**
  String get homeSeeStatistics;

  /// No description provided for @homeMoments.
  ///
  /// In en, this message translates to:
  /// **'Moments'**
  String get homeMoments;

  /// No description provided for @homeBenefits.
  ///
  /// In en, this message translates to:
  /// **'Benefits'**
  String get homeBenefits;

  /// No description provided for @homePathCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Title content to continue lorem ipsuim'**
  String get homePathCardTitle;

  /// No description provided for @homeMonthStatsDescription.
  ///
  /// In en, this message translates to:
  /// **'Lorem ipsum dolor sit amet consectetur. Facilisi varius.'**
  String get homeMonthStatsDescription;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabPath.
  ///
  /// In en, this message translates to:
  /// **'Path'**
  String get tabPath;

  /// No description provided for @tabDiary.
  ///
  /// In en, this message translates to:
  /// **'Diary'**
  String get tabDiary;

  /// No description provided for @tabBenefits.
  ///
  /// In en, this message translates to:
  /// **'Benefits'**
  String get tabBenefits;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @pathTitle.
  ///
  /// In en, this message translates to:
  /// **'Your path'**
  String get pathTitle;

  /// No description provided for @pathOverallProgress.
  ///
  /// In en, this message translates to:
  /// **'Overall progress'**
  String get pathOverallProgress;

  /// No description provided for @pathActivitiesCompleted.
  ///
  /// In en, this message translates to:
  /// **'Activities completed'**
  String get pathActivitiesCompleted;

  /// No description provided for @diaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Diary'**
  String get diaryTitle;

  /// No description provided for @benefitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Benefits'**
  String get benefitsTitle;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// Logout action label in the profile screen
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get profileLogout;

  /// Title of the logout confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get logoutConfirmationTitle;

  /// Body of the logout confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmationMessage;

  /// Confirm button in the logout dialog
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logoutConfirm;

  /// Cancel button in the logout dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get logoutCancel;

  /// No description provided for @statisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statisticsTitle;

  /// No description provided for @statisticsMonth.
  ///
  /// In en, this message translates to:
  /// **'Current month'**
  String get statisticsMonth;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @surveyNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get surveyNext;

  /// No description provided for @surveyVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get surveyVerify;

  /// No description provided for @surveyStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get surveyStart;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get notificationsEmpty;

  /// No description provided for @notificationArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive notification'**
  String get notificationArchive;

  /// No description provided for @notificationsFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get notificationsFilterAll;

  /// No description provided for @notificationsFilterUnread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get notificationsFilterUnread;

  /// No description provided for @notificationsFilterRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get notificationsFilterRead;

  /// No description provided for @notificationsFilterArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get notificationsFilterArchived;

  /// No description provided for @benefitDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get benefitDetails;

  /// No description provided for @benefitsPrimaryPartners.
  ///
  /// In en, this message translates to:
  /// **'Primary Partners'**
  String get benefitsPrimaryPartners;

  /// No description provided for @benefitsSecondaryPartners.
  ///
  /// In en, this message translates to:
  /// **'Secondary Partners'**
  String get benefitsSecondaryPartners;

  /// No description provided for @benefitViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get benefitViewDetails;

  /// No description provided for @benefitsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No benefits available'**
  String get benefitsEmpty;

  /// No description provided for @diaryCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get diaryCompleted;

  /// No description provided for @diaryPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get diaryPending;

  /// No description provided for @areaTraining.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get areaTraining;

  /// No description provided for @areaNutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get areaNutrition;

  /// No description provided for @areaWellbeing.
  ///
  /// In en, this message translates to:
  /// **'Wellbeing'**
  String get areaWellbeing;

  /// No description provided for @areaIntegration.
  ///
  /// In en, this message translates to:
  /// **'Integration'**
  String get areaIntegration;

  /// No description provided for @month1.
  ///
  /// In en, this message translates to:
  /// **'Month 1'**
  String get month1;

  /// No description provided for @phase1.
  ///
  /// In en, this message translates to:
  /// **'Phase 1'**
  String get phase1;

  /// Activity counter (e.g. 3/15 activities)
  ///
  /// In en, this message translates to:
  /// **'{completed}/{total} activities'**
  String activitiesCount(int completed, int total);

  /// No description provided for @pathCompletedPercent.
  ///
  /// In en, this message translates to:
  /// **'completed at {percent}%'**
  String pathCompletedPercent(int percent);

  /// No description provided for @pathStepContentTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get pathStepContentTitle;

  /// No description provided for @pathStepComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete activity'**
  String get pathStepComplete;

  /// No description provided for @pathStepLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get pathStepLocked;

  /// No description provided for @pathStepCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get pathStepCurrent;

  /// No description provided for @pathStepCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get pathStepCompleted;

  /// No description provided for @pathStepStarted.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get pathStepStarted;

  /// No description provided for @pathAreaProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'Your path'**
  String get pathAreaProgressLabel;

  /// No description provided for @pathMaterialsTitle.
  ///
  /// In en, this message translates to:
  /// **'Extra materials'**
  String get pathMaterialsTitle;

  /// No description provided for @pathMaterialsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Useful resources for your path'**
  String get pathMaterialsSubtitle;

  /// No description provided for @pathTimeframeStepsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 activity} other{{count} activities}}'**
  String pathTimeframeStepsCount(int count);

  /// No description provided for @pathTimeframeLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get pathTimeframeLocked;

  /// No description provided for @pathTimeframeCurrent.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get pathTimeframeCurrent;

  /// No description provided for @pathAreaLocked.
  ///
  /// In en, this message translates to:
  /// **'This path is not available yet.'**
  String get pathAreaLocked;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
