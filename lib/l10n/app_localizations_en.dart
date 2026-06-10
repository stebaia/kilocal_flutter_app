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
  String get loginEmail => 'Email';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginButton => 'Sign in';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginNoAccount => 'Don\'t have an account?';

  @override
  String get loginSignUp => 'Sign up';

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
  String get diaryTitle => 'Diary';

  @override
  String get benefitsTitle => 'Benefits';

  @override
  String get profileTitle => 'Profile';

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
  String get benefitDetails => 'Details';

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
}
