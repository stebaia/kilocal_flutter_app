// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Kilocal';

  @override
  String get splashLoading => 'Loading...';

  @override
  String get onboardingTitle1 => 'Welcome to Kilocal';

  @override
  String get onboardingBody1 =>
      'Start your personalized wellness journey with us.';

  @override
  String get onboardingTitle2 => 'Follow your path';

  @override
  String get onboardingBody2 =>
      'Training, nutrition, wellbeing and integration in one place.';

  @override
  String get onboardingTitle3 => 'Track your progress';

  @override
  String get onboardingBody3 => 'Monitor your results and achieve your goals.';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Start';

  @override
  String get loginTitle => 'Login';

  @override
  String get loginSubtitle =>
      'Lorem ipsum dolor sit amet consectetur. Ullamcorper quis lacus.';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginButton => 'Sign in';

  @override
  String get loginForgotPrompt => 'Forgot your password?';

  @override
  String get loginForgotLink => 'Recover it here';

  @override
  String get loginNoAccount => 'Don\'t have an account?';

  @override
  String get loginSignUp => 'Sign up';

  @override
  String get registerTitle => 'Sign up';

  @override
  String get registerSubtitle =>
      'Lorem ipsum dolor sit amet consectetur. Ullamcorper quis lacus.';

  @override
  String get registerFullName => 'Full name';

  @override
  String get registerEmail => 'Email address';

  @override
  String get registerPassword => 'Password';

  @override
  String get registerPasswordConfirm => 'Confirm password';

  @override
  String get registerTermsPrefix => 'By signing up you accept the';

  @override
  String get registerTermsLink => 'terms and conditions';

  @override
  String get registerButton => 'Sign up';

  @override
  String get registerBottomPrompt => 'Not registered?';

  @override
  String get registerBottomLink => 'Sign up now';

  @override
  String get registerSuccessTitle => 'Registration completed';

  @override
  String get registerSuccessDescription =>
      'You can now log in with your credentials.';

  @override
  String get errorTitle => 'Error';

  @override
  String get registerErrorMissingFields =>
      'Fill in all required fields and accept the terms.';

  @override
  String get registerErrorPasswordMismatch => 'Passwords do not match.';

  @override
  String get registerErrorConflict => 'Email already registered.';

  @override
  String get registerErrorBadRequest =>
      'Invalid data. Please check the entered fields.';

  @override
  String get registerErrorNetwork => 'No connection. Please try again later.';

  @override
  String get registerErrorServer => 'Server error. Please try again later.';

  @override
  String get registerErrorGeneric => 'Something went wrong. Please try again.';

  @override
  String get loginErrorMissingFields => 'Enter email and password.';

  @override
  String get loginErrorUnauthorized => 'Invalid email or password.';

  @override
  String get loginErrorBadRequest =>
      'Invalid data. Please check email and password.';

  @override
  String get loginErrorNetwork => 'No connection. Please try again later.';

  @override
  String get loginErrorServer => 'Server error. Please try again later.';

  @override
  String get loginErrorGeneric => 'Something went wrong. Please try again.';

  @override
  String homeGreeting(String name) {
    return 'Hello $name';
  }

  @override
  String get homeProgress => 'Overall progress';

  @override
  String get homeQuickLinks => 'Quick links';

  @override
  String get homeHeroTitle => 'For you';

  @override
  String get homeContinuePath => 'Continue the path';

  @override
  String get homeSeeStatistics => 'See statistics';

  @override
  String get homeMoments => 'Moments';

  @override
  String get homeBenefits => 'Benefits';

  @override
  String get homePathCardTitle => 'Title content to continue lorem ipsuim';

  @override
  String get homeMonthStatsDescription =>
      'Lorem ipsum dolor sit amet consectetur. Facilisi varius.';

  @override
  String get tabHome => 'Home';

  @override
  String get tabPath => 'Path';

  @override
  String get tabDiary => 'Diary';

  @override
  String get tabBenefits => 'Benefits';

  @override
  String get tabProfile => 'Profile';

  @override
  String get pathTitle => 'Your path';

  @override
  String get pathOverallProgress => 'Overall progress';

  @override
  String get pathActivitiesCompleted => 'Activities completed';

  @override
  String get diaryTitle => 'Diary';

  @override
  String get benefitsTitle => 'Benefits';

  @override
  String get profileTitle => 'Your Profile';

  @override
  String get profileMyTypeSection => 'My Type';

  @override
  String get profileMyTypeValue => 'Type 4 - Pear';

  @override
  String get profileCategorySection => 'Section category name';

  @override
  String get profilePersonalData => 'My personal data';

  @override
  String get profileMyAccount => 'My account';

  @override
  String get profileFoodPreferences => 'Food preferences';

  @override
  String get profileNotificationsSection => 'Notifications';

  @override
  String get profilePushNotifications => 'Push notifications';

  @override
  String get profilePushNotificationsStatus => 'Active';

  @override
  String get profileSupportSection => 'Support';

  @override
  String get profileTutorial => 'Tutorial on how to use the app';

  @override
  String get profileContactSupport => 'Contact support';

  @override
  String get profileLogout => 'Log out';

  @override
  String get logoutConfirmationTitle => 'Log out?';

  @override
  String get logoutConfirmationMessage => 'Are you sure you want to log out?';

  @override
  String get logoutConfirm => 'Log out';

  @override
  String get logoutCancel => 'Cancel';

  @override
  String get statisticsTitle => 'Statistics';

  @override
  String get statisticsMonth => 'Current month';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get retry => 'Retry';

  @override
  String get surveyNext => 'Next';

  @override
  String get surveyVerify => 'Verify';

  @override
  String get surveyStart => 'Start';

  @override
  String get notificationsEmpty => 'No notifications';

  @override
  String get notificationArchive => 'Archive notification';

  @override
  String get notificationsFilterAll => 'All';

  @override
  String get notificationsFilterUnread => 'Unread';

  @override
  String get notificationsFilterRead => 'Read';

  @override
  String get notificationsFilterArchived => 'Archived';

  @override
  String get benefitDetails => 'Details';

  @override
  String get benefitsPrimaryPartners => 'Primary Partners';

  @override
  String get benefitsSecondaryPartners => 'Secondary Partners';

  @override
  String get benefitViewDetails => 'View details';

  @override
  String get benefitsEmpty => 'No benefits available';

  @override
  String get momentiTitle => 'Moments';

  @override
  String get momentiEmpty => 'No moments available';

  @override
  String get diaryCompleted => 'Completed';

  @override
  String get diaryPending => 'Pending';

  @override
  String get areaTraining => 'Training';

  @override
  String get areaNutrition => 'Nutrition';

  @override
  String get areaWellbeing => 'Wellbeing';

  @override
  String get areaIntegration => 'Integration';

  @override
  String get month1 => 'Month 1';

  @override
  String get phase1 => 'Phase 1';

  @override
  String activitiesCount(int completed, int total) {
    return '$completed/$total activities';
  }

  @override
  String pathCompletedPercent(int percent) {
    return 'completed at $percent%';
  }

  @override
  String get pathStepContentTitle => 'Activity';

  @override
  String get pathStepComplete => 'Complete activity';

  @override
  String get pathStepLocked => 'Locked';

  @override
  String get pathStepCurrent => 'Current';

  @override
  String get pathStepCompleted => 'Completed';

  @override
  String get pathStepStarted => 'Started';

  @override
  String pathStepVideoDuration(String duration) {
    return '$duration min';
  }

  @override
  String get commonClose => 'Close';

  @override
  String get pathActivitiesTitle => 'Activities';

  @override
  String pathActivitiesTotal(int count) {
    return '$count total';
  }

  @override
  String get pathTimerSetTitle => 'Set Timer';

  @override
  String get pathTimerHours => 'Hours';

  @override
  String get pathTimerMinutes => 'Minutes';

  @override
  String get pathTimerSeconds => 'Seconds';

  @override
  String get pathTimerStart => 'Start timer';

  @override
  String pathTimerPill(String time) {
    return 'Timer: $time';
  }

  @override
  String get pathAreaProgressLabel => 'Your path';

  @override
  String get pathMaterialsTitle => 'Extra materials';

  @override
  String get pathMaterialsSubtitle => 'Useful resources for your path';

  @override
  String get pathMaterialAvailable => 'Available';

  @override
  String get pathMaterialsEmpty => 'No materials available';

  @override
  String get pathMaterialsFilterAvailable => 'Available';

  @override
  String get pathMaterialsFilterCompleted => 'Completed';

  @override
  String get pathMaterialsFilterUnavailable => 'Unavailable';

  @override
  String pathTimeframeStepsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count activities',
      one: '1 activity',
    );
    return '$_temp0';
  }

  @override
  String get pathTimeframeLocked => 'Locked';

  @override
  String get pathTimeframeCurrent => 'In progress';

  @override
  String get pathAreaLocked => 'This path is not available yet.';
}
