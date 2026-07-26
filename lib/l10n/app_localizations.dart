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
  /// **'Let\'s start'**
  String get onboardingStart;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Every day one step closer to your body recomposition.'**
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
  /// **'To discover your type and the path tailored for you, fill in the form and start the test.'**
  String get registerSubtitle;

  /// No description provided for @registerFirstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get registerFirstName;

  /// No description provided for @registerLastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get registerLastName;

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
  /// **'Already have an account?'**
  String get registerBottomPrompt;

  /// No description provided for @registerBottomLink.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
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

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Recover password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your account email. We\'ll send you a link to reset your password.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @forgotPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Send link'**
  String get forgotPasswordButton;

  /// No description provided for @forgotPasswordBackPrompt.
  ///
  /// In en, this message translates to:
  /// **'Remembered your password?'**
  String get forgotPasswordBackPrompt;

  /// No description provided for @forgotPasswordBackLink.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get forgotPasswordBackLink;

  /// No description provided for @forgotPasswordSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get forgotPasswordSuccessTitle;

  /// No description provided for @forgotPasswordSuccessDescription.
  ///
  /// In en, this message translates to:
  /// **'If the address is linked to an account, you\'ll receive a link to reset your password.'**
  String get forgotPasswordSuccessDescription;

  /// No description provided for @forgotPasswordErrorMissingEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email.'**
  String get forgotPasswordErrorMissingEmail;

  /// No description provided for @forgotPasswordErrorBadRequest.
  ///
  /// In en, this message translates to:
  /// **'Invalid email. Please check and try again.'**
  String get forgotPasswordErrorBadRequest;

  /// No description provided for @forgotPasswordErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No connection. Please try again later.'**
  String get forgotPasswordErrorNetwork;

  /// No description provided for @forgotPasswordErrorServer.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get forgotPasswordErrorServer;

  /// No description provided for @forgotPasswordErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get forgotPasswordErrorGeneric;

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

  /// No description provided for @homeStartPath.
  ///
  /// In en, this message translates to:
  /// **'Start the path'**
  String get homeStartPath;

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

  /// Title of the bottom sheet shown when a restricted user taps a locked path area.
  ///
  /// In en, this message translates to:
  /// **'Locked content'**
  String get pathLockedTitle;

  /// Body copy of the locked-content bottom sheet.
  ///
  /// In en, this message translates to:
  /// **'This content is not available with your current plan. Buy your starter kit to unlock the full programme.'**
  String get pathLockedBody;

  /// No description provided for @pathLockedUnderstood.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get pathLockedUnderstood;

  /// No description provided for @pathLockedBoughtKit.
  ///
  /// In en, this message translates to:
  /// **'I bought the Starter kit'**
  String get pathLockedBoughtKit;

  /// Title of the sheet shown when tapping a month that is locked pending completion of the previous one.
  ///
  /// In en, this message translates to:
  /// **'Month locked'**
  String get pathTimeframeLockedTitle;

  /// Body copy of the timeframe-locked sheet.
  ///
  /// In en, this message translates to:
  /// **'To unlock this month, complete every activity in the previous month first.'**
  String get pathTimeframeLockedBody;

  /// Title of the sheet shown after completing the last activity of a month.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get pathMonthCompletedTitle;

  /// Body copy of the month-completed sheet.
  ///
  /// In en, this message translates to:
  /// **'You\'ve completed every activity for this month.'**
  String get pathMonthCompletedBody;

  /// CTA on the month-completed sheet, opens the statistics screen.
  ///
  /// In en, this message translates to:
  /// **'See statistics'**
  String get pathMonthCompletedCta;

  /// Title of the barcode-entry bottom sheet used to unlock the programme.
  ///
  /// In en, this message translates to:
  /// **'Unlock the programme'**
  String get pathUnlockTitle;

  /// Instructions above the barcode input in the unlock sheet.
  ///
  /// In en, this message translates to:
  /// **'Enter the barcode printed on the pack of the Kilocal product you bought. The code is 1 letter followed by 9 digits.'**
  String get pathUnlockInstructions;

  /// No description provided for @pathUnlockCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter proof-of-purchase code…'**
  String get pathUnlockCodeHint;

  /// No description provided for @pathUnlockSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get pathUnlockSubmit;

  /// No description provided for @pathUnlockInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'This code doesn\'t match any Kilocal product. Check it and try again.'**
  String get pathUnlockInvalidCode;

  /// No description provided for @pathUnlockSuccess.
  ///
  /// In en, this message translates to:
  /// **'Programme unlocked!'**
  String get pathUnlockSuccess;

  /// No description provided for @diaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity diary'**
  String get diaryTitle;

  /// No description provided for @benefitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Benefits'**
  String get benefitsTitle;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Profile'**
  String get profileTitle;

  /// No description provided for @profileMyTypeSection.
  ///
  /// In en, this message translates to:
  /// **'My Type'**
  String get profileMyTypeSection;

  /// No description provided for @profileMyTypeValue.
  ///
  /// In en, this message translates to:
  /// **'Type 4 - Pear'**
  String get profileMyTypeValue;

  /// No description provided for @profileTypeUnknown.
  ///
  /// In en, this message translates to:
  /// **'My Type'**
  String get profileTypeUnknown;

  /// No description provided for @profileTypeCharacteristics.
  ///
  /// In en, this message translates to:
  /// **'Your characteristics'**
  String get profileTypeCharacteristics;

  /// No description provided for @profileTypeDiscoverMore.
  ///
  /// In en, this message translates to:
  /// **'Discover more'**
  String get profileTypeDiscoverMore;

  /// Title pill on the biotype body-map card; {type} is the biotype label e.g. 'Type 1'.
  ///
  /// In en, this message translates to:
  /// **'{type} - Your starting point'**
  String profileTypeStartingPoint(String type);

  /// Label above the four path-category buttons on the biotype characteristics screen.
  ///
  /// In en, this message translates to:
  /// **'The path to feel your best'**
  String get profileTypePathToFeelBest;

  /// Fallback title in the body-map point sheet when a point has no text.
  ///
  /// In en, this message translates to:
  /// **'Body point'**
  String get profileTypePointTitleFallback;

  /// Fallback body in the body-map point/area sheet when there is no text.
  ///
  /// In en, this message translates to:
  /// **'Content coming soon.'**
  String get profileTypePointBodyFallback;

  /// Title of the intermediate sheet shown before entering the Integrazione area.
  ///
  /// In en, this message translates to:
  /// **'Integration'**
  String get profileTypeIntegrationSheetTitle;

  /// Bold headline in the Integrazione intermediate sheet.
  ///
  /// In en, this message translates to:
  /// **'Your Kilocal path isn\'t just nutrition and movement!'**
  String get profileTypeIntegrationSheetHeadline;

  /// Body copy in the Integrazione intermediate sheet.
  ///
  /// In en, this message translates to:
  /// **'The supplement kit is designed to support you step by step, reactivating your body\'s energy and boosting your path\'s results.'**
  String get profileTypeIntegrationSheetBody;

  /// CTA button in the Integrazione intermediate sheet; navigates to the Integrazione area.
  ///
  /// In en, this message translates to:
  /// **'See dedicated section'**
  String get profileTypeIntegrationSheetCta;

  /// No description provided for @profileTypeProductsSection.
  ///
  /// In en, this message translates to:
  /// **'Product information'**
  String get profileTypeProductsSection;

  /// No description provided for @profileTypeMyKit.
  ///
  /// In en, this message translates to:
  /// **'My Kit'**
  String get profileTypeMyKit;

  /// No description provided for @profileTypeSupplements.
  ///
  /// In en, this message translates to:
  /// **'Supplements and products'**
  String get profileTypeSupplements;

  /// No description provided for @profileKitTitle.
  ///
  /// In en, this message translates to:
  /// **'Kit {type}'**
  String profileKitTitle(String type);

  /// No description provided for @profileKitBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get profileKitBuy;

  /// No description provided for @profileKitEmpty.
  ///
  /// In en, this message translates to:
  /// **'No products available.'**
  String get profileKitEmpty;

  /// No description provided for @profileCategorySection.
  ///
  /// In en, this message translates to:
  /// **'Section category name'**
  String get profileCategorySection;

  /// No description provided for @profilePersonalData.
  ///
  /// In en, this message translates to:
  /// **'My personal data'**
  String get profilePersonalData;

  /// No description provided for @profileMyAccount.
  ///
  /// In en, this message translates to:
  /// **'My account'**
  String get profileMyAccount;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved'**
  String get profileSaved;

  /// No description provided for @profileAvatarChange.
  ///
  /// In en, this message translates to:
  /// **'Change profile photo'**
  String get profileAvatarChange;

  /// No description provided for @profileAvatarFromCamera.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get profileAvatarFromCamera;

  /// No description provided for @profileAvatarFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get profileAvatarFromGallery;

  /// No description provided for @profileAvatarUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile photo updated'**
  String get profileAvatarUpdated;

  /// No description provided for @profileAvatarError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update the profile photo'**
  String get profileAvatarError;

  /// No description provided for @profileChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get profileChangePassword;

  /// No description provided for @profileChangePasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password for your account.'**
  String get profileChangePasswordHint;

  /// No description provided for @profileNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get profileNewPassword;

  /// No description provided for @profileConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get profileConfirmPassword;

  /// No description provided for @profileChangePasswordSubmit.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get profileChangePasswordSubmit;

  /// No description provided for @profilePasswordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated'**
  String get profilePasswordUpdated;

  /// No description provided for @profilePasswordError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update the password'**
  String get profilePasswordError;

  /// No description provided for @profilePasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least {count} characters'**
  String profilePasswordTooShort(int count);

  /// No description provided for @profilePasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'The two passwords don\'t match'**
  String get profilePasswordMismatch;

  /// No description provided for @profileFoodPreferences.
  ///
  /// In en, this message translates to:
  /// **'Food preferences'**
  String get profileFoodPreferences;

  /// Expander that reveals the full checkbox list of options for a food-preference multi-select (e.g. intolerances).
  ///
  /// In en, this message translates to:
  /// **'Add or edit'**
  String get profileFoodPreferencesEdit;

  /// Shown in place of the chips when the user has not picked any option for a food-preference multi-select.
  ///
  /// In en, this message translates to:
  /// **'No selection'**
  String get profileFoodPreferencesEmpty;

  /// No description provided for @profileNotificationsSection.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileNotificationsSection;

  /// No description provided for @profilePushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get profilePushNotifications;

  /// No description provided for @profilePushNotificationsStatus.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get profilePushNotificationsStatus;

  /// No description provided for @profileSupportSection.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get profileSupportSection;

  /// No description provided for @profileTutorial.
  ///
  /// In en, this message translates to:
  /// **'Tutorial on how to use the app'**
  String get profileTutorial;

  /// No description provided for @profileContactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get profileContactSupport;

  /// Logout action label in the profile screen
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get profileLogout;

  /// No description provided for @profileAppVersionSection.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get profileAppVersionSection;

  /// No description provided for @profileAppVersion.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get profileAppVersion;

  /// No description provided for @profileAppVersionValue.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String profileAppVersionValue(String version);

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

  /// No description provided for @surveyFindPharmacy.
  ///
  /// In en, this message translates to:
  /// **'Find a Kilocal Point pharmacy'**
  String get surveyFindPharmacy;

  /// No description provided for @surveyGoToShop.
  ///
  /// In en, this message translates to:
  /// **'Go to the shop'**
  String get surveyGoToShop;

  /// No description provided for @surveyEnterProofOfPurchase.
  ///
  /// In en, this message translates to:
  /// **'Enter proof of purchase'**
  String get surveyEnterProofOfPurchase;

  /// No description provided for @surveyNoStarterKit.
  ///
  /// In en, this message translates to:
  /// **'I don\'t have a Starter Kit'**
  String get surveyNoStarterKit;

  /// No description provided for @surveyErrorNotANumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get surveyErrorNotANumber;

  /// No description provided for @surveyErrorNotAnInteger.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number'**
  String get surveyErrorNotAnInteger;

  /// No description provided for @surveyErrorTooSmall.
  ///
  /// In en, this message translates to:
  /// **'That value is too low'**
  String get surveyErrorTooSmall;

  /// No description provided for @surveyErrorTooLarge.
  ///
  /// In en, this message translates to:
  /// **'That value is too high'**
  String get surveyErrorTooLarge;

  /// No description provided for @surveyErrorNotADate.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid date'**
  String get surveyErrorNotADate;

  /// No description provided for @surveyErrorDateTooLate.
  ///
  /// In en, this message translates to:
  /// **'You must be at least 18'**
  String get surveyErrorDateTooLate;

  /// No description provided for @surveyErrorDateTooEarly.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid date'**
  String get surveyErrorDateTooEarly;

  /// No description provided for @surveyErrorBmiTooLow.
  ///
  /// In en, this message translates to:
  /// **'That weight is not compatible with your height'**
  String get surveyErrorBmiTooLow;

  /// No description provided for @surveyErrorInvalidZipCode.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid postcode (5 digits)'**
  String get surveyErrorInvalidZipCode;

  /// No description provided for @surveyErrorInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get surveyErrorInvalidPhone;

  /// No description provided for @surveyErrorInvalidBarcode.
  ///
  /// In en, this message translates to:
  /// **'Barcode not recognised. Check the code on your Starter Kit pack.'**
  String get surveyErrorInvalidBarcode;

  /// No description provided for @surveyBarcodeChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking the code…'**
  String get surveyBarcodeChecking;

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

  /// No description provided for @benefitClaimReward.
  ///
  /// In en, this message translates to:
  /// **'Claim the reward'**
  String get benefitClaimReward;

  /// No description provided for @benefitClaimRewardError.
  ///
  /// In en, this message translates to:
  /// **'Unable to open the reward link'**
  String get benefitClaimRewardError;

  /// No description provided for @benefitVisitSite.
  ///
  /// In en, this message translates to:
  /// **'Visit the {partner} website'**
  String benefitVisitSite(String partner);

  /// No description provided for @benefitCouponCopied.
  ///
  /// In en, this message translates to:
  /// **'Discount code copied'**
  String get benefitCouponCopied;

  /// No description provided for @benefitsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No benefits available'**
  String get benefitsEmpty;

  /// No description provided for @momentiTitle.
  ///
  /// In en, this message translates to:
  /// **'Moments'**
  String get momentiTitle;

  /// No description provided for @momentiEmpty.
  ///
  /// In en, this message translates to:
  /// **'No moments available'**
  String get momentiEmpty;

  /// No description provided for @momentiInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get momentiInfoTitle;

  /// No description provided for @momentiInfoTooltip.
  ///
  /// In en, this message translates to:
  /// **'Information about this moment'**
  String get momentiInfoTooltip;

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

  /// No description provided for @integrationCurrentPhase.
  ///
  /// In en, this message translates to:
  /// **'Current phase'**
  String get integrationCurrentPhase;

  /// No description provided for @integrationNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Not started yet'**
  String get integrationNotStarted;

  /// No description provided for @integrationPhasesTitle.
  ///
  /// In en, this message translates to:
  /// **'Your plan'**
  String get integrationPhasesTitle;

  /// No description provided for @integrationEmpty.
  ///
  /// In en, this message translates to:
  /// **'No supplement plan available.'**
  String get integrationEmpty;

  /// No description provided for @integrationProductDuration.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day} other{{days} days}}'**
  String integrationProductDuration(int days);

  /// No description provided for @integrationProductQuantity.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 per day} other{{count} per day}}'**
  String integrationProductQuantity(int count);

  /// No description provided for @integrationPhaseLabel.
  ///
  /// In en, this message translates to:
  /// **'Phase {number}'**
  String integrationPhaseLabel(int number);

  /// No description provided for @integrationCompletePhaseFirst.
  ///
  /// In en, this message translates to:
  /// **'Complete phase {number} first'**
  String integrationCompletePhaseFirst(int number);

  /// No description provided for @integrationPhaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Integration Phase {number}'**
  String integrationPhaseTitle(int number);

  /// No description provided for @integrationMonitoringWeeks.
  ///
  /// In en, this message translates to:
  /// **'{weeks, plural, =1{1 week tracking} other{{weeks} weeks tracking}}'**
  String integrationMonitoringWeeks(int weeks);

  /// No description provided for @integrationMonitoringDays.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day tracking} other{{days} days tracking}}'**
  String integrationMonitoringDays(int days);

  /// No description provided for @integrationMarkTaken.
  ///
  /// In en, this message translates to:
  /// **'Mark supplement as taken'**
  String get integrationMarkTaken;

  /// No description provided for @integrationTakenToday.
  ///
  /// In en, this message translates to:
  /// **'Taken today'**
  String get integrationTakenToday;

  /// No description provided for @integrationMarkTakenError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t record the intake. Try again later.'**
  String get integrationMarkTakenError;

  /// No description provided for @integrationMarkedTaken.
  ///
  /// In en, this message translates to:
  /// **'Intake recorded'**
  String get integrationMarkedTaken;

  /// No description provided for @integrationInstructionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Usage instructions'**
  String get integrationInstructionsTitle;

  /// No description provided for @integrationStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start date:'**
  String get integrationStartDate;

  /// No description provided for @integrationExpectedEndDate.
  ///
  /// In en, this message translates to:
  /// **'Expected end date:'**
  String get integrationExpectedEndDate;

  /// No description provided for @integrationEnableReminder.
  ///
  /// In en, this message translates to:
  /// **'Enable reminder'**
  String get integrationEnableReminder;

  /// No description provided for @integrationReminderActiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Reminder active: {label}'**
  String integrationReminderActiveLabel(String label);

  /// No description provided for @integrationReminderSnooze2hShort.
  ///
  /// In en, this message translates to:
  /// **'snooze 2 hours'**
  String get integrationReminderSnooze2hShort;

  /// No description provided for @integrationReminderSnooze4hShort.
  ///
  /// In en, this message translates to:
  /// **'snooze 4 hours'**
  String get integrationReminderSnooze4hShort;

  /// No description provided for @integrationReminderSnooze8hShort.
  ///
  /// In en, this message translates to:
  /// **'snooze 8 hours'**
  String get integrationReminderSnooze8hShort;

  /// No description provided for @integrationReminderSnooze1dShort.
  ///
  /// In en, this message translates to:
  /// **'snooze 1 day'**
  String get integrationReminderSnooze1dShort;

  /// No description provided for @integrationReminderEnabled.
  ///
  /// In en, this message translates to:
  /// **'Reminder enabled'**
  String get integrationReminderEnabled;

  /// No description provided for @integrationReminderError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t enable the reminder. Check your notification permissions.'**
  String get integrationReminderError;

  /// No description provided for @integrationReminderAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add reminder'**
  String get integrationReminderAddTitle;

  /// No description provided for @integrationReminderEditDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit or delete reminder'**
  String get integrationReminderEditDeleteTitle;

  /// No description provided for @integrationReminderEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit reminder'**
  String get integrationReminderEditTitle;

  /// No description provided for @integrationReminderSelectTime.
  ///
  /// In en, this message translates to:
  /// **'Select time'**
  String get integrationReminderSelectTime;

  /// No description provided for @integrationReminderConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get integrationReminderConfirm;

  /// No description provided for @integrationReminderSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get integrationReminderSave;

  /// No description provided for @integrationReminderCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get integrationReminderCancel;

  /// No description provided for @integrationReminderEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get integrationReminderEdit;

  /// No description provided for @integrationReminderDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get integrationReminderDelete;

  /// No description provided for @integrationReminderDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this reminder?'**
  String get integrationReminderDeleteConfirm;

  /// No description provided for @integrationReminderDeleted.
  ///
  /// In en, this message translates to:
  /// **'Reminder deleted'**
  String get integrationReminderDeleted;

  /// No description provided for @integrationReminderMessage.
  ///
  /// In en, this message translates to:
  /// **'Take the product \"{product}\". This message is generated automatically.'**
  String integrationReminderMessage(String product);

  /// No description provided for @integrationReminderSnoozedLabel.
  ///
  /// In en, this message translates to:
  /// **'Snoozed by {label}'**
  String integrationReminderSnoozedLabel(String label);

  /// No description provided for @integrationReminderSnooze2h.
  ///
  /// In en, this message translates to:
  /// **'Snooze 2 hours'**
  String get integrationReminderSnooze2h;

  /// No description provided for @integrationReminderSnooze4h.
  ///
  /// In en, this message translates to:
  /// **'Snooze 4 hours'**
  String get integrationReminderSnooze4h;

  /// No description provided for @integrationReminderSnooze8h.
  ///
  /// In en, this message translates to:
  /// **'Snooze 8 hours'**
  String get integrationReminderSnooze8h;

  /// No description provided for @integrationReminderSnooze1d.
  ///
  /// In en, this message translates to:
  /// **'Snooze 1 day'**
  String get integrationReminderSnooze1d;

  /// No description provided for @diaryTabHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get diaryTabHistory;

  /// No description provided for @diaryTabGoals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get diaryTabGoals;

  /// No description provided for @diaryHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No activity recorded yet.'**
  String get diaryHistoryEmpty;

  /// No description provided for @diaryGoalsEmpty.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any goals yet.'**
  String get diaryGoalsEmpty;

  /// No description provided for @diaryGoalPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get diaryGoalPersonal;

  /// No description provided for @diaryGoalKilocal.
  ///
  /// In en, this message translates to:
  /// **'Kilocal'**
  String get diaryGoalKilocal;

  /// No description provided for @diaryGoalCompleted.
  ///
  /// In en, this message translates to:
  /// **'Achieved'**
  String get diaryGoalCompleted;

  /// No description provided for @diaryFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All goals'**
  String get diaryFilterAll;

  /// No description provided for @diaryFilterPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal goals'**
  String get diaryFilterPersonal;

  /// No description provided for @diaryFilterKilocal.
  ///
  /// In en, this message translates to:
  /// **'Kilocal goals'**
  String get diaryFilterKilocal;

  /// No description provided for @diaryFilterCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get diaryFilterCompleted;

  /// No description provided for @diaryGoalCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'New goal'**
  String get diaryGoalCreateTitle;

  /// No description provided for @diaryGoalContentHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your goal'**
  String get diaryGoalContentHint;

  /// No description provided for @diaryGoalCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get diaryGoalCategory;

  /// No description provided for @diaryGoalPickDate.
  ///
  /// In en, this message translates to:
  /// **'Add a date'**
  String get diaryGoalPickDate;

  /// No description provided for @diaryGoalSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get diaryGoalSave;

  /// No description provided for @diaryActivityDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity details'**
  String get diaryActivityDetailTitle;

  /// No description provided for @diaryActivityCategory.
  ///
  /// In en, this message translates to:
  /// **'Category: {category}'**
  String diaryActivityCategory(String category);

  /// No description provided for @diaryActivityPlannedOn.
  ///
  /// In en, this message translates to:
  /// **'Planned completion: {date}'**
  String diaryActivityPlannedOn(String date);

  /// No description provided for @diaryActivityToComplete.
  ///
  /// In en, this message translates to:
  /// **'To complete: {date}'**
  String diaryActivityToComplete(String date);

  /// No description provided for @diaryActivityCompleteError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t complete the activity. Try again.'**
  String get diaryActivityCompleteError;

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

  /// No description provided for @pathStepVideoDuration.
  ///
  /// In en, this message translates to:
  /// **'{duration} min'**
  String pathStepVideoDuration(String duration);

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @pathActivitiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get pathActivitiesTitle;

  /// No description provided for @pathActivitiesTotal.
  ///
  /// In en, this message translates to:
  /// **'{count} total'**
  String pathActivitiesTotal(int count);

  /// No description provided for @pathTimerSetTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Timer'**
  String get pathTimerSetTitle;

  /// No description provided for @pathTimerHours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get pathTimerHours;

  /// No description provided for @pathTimerMinutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get pathTimerMinutes;

  /// No description provided for @pathTimerSeconds.
  ///
  /// In en, this message translates to:
  /// **'Seconds'**
  String get pathTimerSeconds;

  /// No description provided for @pathTimerStart.
  ///
  /// In en, this message translates to:
  /// **'Start timer'**
  String get pathTimerStart;

  /// No description provided for @pathTimerPill.
  ///
  /// In en, this message translates to:
  /// **'Timer: {time}'**
  String pathTimerPill(String time);

  /// No description provided for @pathTimerStop.
  ///
  /// In en, this message translates to:
  /// **'stop'**
  String get pathTimerStop;

  /// No description provided for @pathTimerPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pathTimerPause;

  /// No description provided for @pathTimerResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get pathTimerResume;

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

  /// No description provided for @pathMaterialsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No materials available'**
  String get pathMaterialsEmpty;

  /// No description provided for @pathMaterialsFilterToWatch.
  ///
  /// In en, this message translates to:
  /// **'To watch'**
  String get pathMaterialsFilterToWatch;

  /// No description provided for @pathMaterialsFilterWatched.
  ///
  /// In en, this message translates to:
  /// **'Watched'**
  String get pathMaterialsFilterWatched;

  /// No description provided for @pathMaterialMarkCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mark as completed'**
  String get pathMaterialMarkCompleted;

  /// No description provided for @pathMaterialCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get pathMaterialCompleted;

  /// No description provided for @pathMaterialDownloadError.
  ///
  /// In en, this message translates to:
  /// **'Could not open the file. Please try again.'**
  String get pathMaterialDownloadError;

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

  /// No description provided for @strumentiTitle.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get strumentiTitle;

  /// No description provided for @strumentiLaunch.
  ///
  /// In en, this message translates to:
  /// **'Launch tool'**
  String get strumentiLaunch;

  /// No description provided for @strumentiPromemoria.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get strumentiPromemoria;

  /// No description provided for @strumentiTimer.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get strumentiTimer;

  /// No description provided for @strumentiGlossario.
  ///
  /// In en, this message translates to:
  /// **'Glossary'**
  String get strumentiGlossario;

  /// No description provided for @strumentiGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get strumentiGallery;

  /// No description provided for @strumentiComingSoon.
  ///
  /// In en, this message translates to:
  /// **'This tool will be available soon.'**
  String get strumentiComingSoon;

  /// No description provided for @glossarioSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get glossarioSearch;

  /// No description provided for @glossarioSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Keyword'**
  String get glossarioSearchHint;

  /// No description provided for @glossarioResults.
  ///
  /// In en, this message translates to:
  /// **'Matching results'**
  String get glossarioResults;

  /// No description provided for @glossarioEmpty.
  ///
  /// In en, this message translates to:
  /// **'No results for this search.'**
  String get glossarioEmpty;

  /// No description provided for @glossarioLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load the glossary.'**
  String get glossarioLoadError;

  /// No description provided for @galleryPhotosTitle.
  ///
  /// In en, this message translates to:
  /// **'My photos'**
  String get galleryPhotosTitle;

  /// No description provided for @galleryUploadTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload image'**
  String get galleryUploadTitle;

  /// No description provided for @galleryUploadInfo.
  ///
  /// In en, this message translates to:
  /// **'Use the button to upload content from your device'**
  String get galleryUploadInfo;

  /// No description provided for @galleryUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get galleryUpload;

  /// No description provided for @galleryTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get galleryTakePhoto;

  /// No description provided for @galleryRetakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get galleryRetakePhoto;

  /// No description provided for @galleryConfirmUpload.
  ///
  /// In en, this message translates to:
  /// **'Confirm and upload'**
  String get galleryConfirmUpload;

  /// No description provided for @galleryUploadError.
  ///
  /// In en, this message translates to:
  /// **'Could not upload the photo. Try again.'**
  String get galleryUploadError;

  /// No description provided for @galleryDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete the photo. Try again.'**
  String get galleryDeleteError;

  /// No description provided for @galleryLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load your photos.'**
  String get galleryLoadError;

  /// No description provided for @galleryEmpty.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t uploaded any photos yet.'**
  String get galleryEmpty;

  /// No description provided for @galleryToolBlocked.
  ///
  /// In en, this message translates to:
  /// **'This tool is not available right now.'**
  String get galleryToolBlocked;

  /// No description provided for @galleryDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get galleryDelete;

  /// No description provided for @galleryCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get galleryCancel;

  /// No description provided for @gallerySplitTitle.
  ///
  /// In en, this message translates to:
  /// **'Split image'**
  String get gallerySplitTitle;

  /// No description provided for @gallerySave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get gallerySave;

  /// No description provided for @galleryShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get galleryShare;

  /// No description provided for @gallerySaved.
  ///
  /// In en, this message translates to:
  /// **'Image saved'**
  String get gallerySaved;

  /// No description provided for @gallerySaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save the image.'**
  String get gallerySaveError;

  /// No description provided for @promemoriaViewList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get promemoriaViewList;

  /// No description provided for @promemoriaViewCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get promemoriaViewCalendar;

  /// No description provided for @promemoriaEmpty.
  ///
  /// In en, this message translates to:
  /// **'No reminders for this month.'**
  String get promemoriaEmpty;

  /// No description provided for @promemoriaLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load reminders.'**
  String get promemoriaLoadError;

  /// No description provided for @promemoriaAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add reminder'**
  String get promemoriaAddTitle;

  /// No description provided for @promemoriaMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get promemoriaMessageLabel;

  /// No description provided for @promemoriaMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the reminder text here'**
  String get promemoriaMessageHint;

  /// No description provided for @promemoriaDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get promemoriaDateLabel;

  /// No description provided for @promemoriaTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get promemoriaTimeLabel;

  /// No description provided for @promemoriaSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get promemoriaSelectDate;

  /// No description provided for @promemoriaSelectTime.
  ///
  /// In en, this message translates to:
  /// **'Select time'**
  String get promemoriaSelectTime;

  /// No description provided for @promemoriaConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get promemoriaConfirm;

  /// No description provided for @promemoriaSave.
  ///
  /// In en, this message translates to:
  /// **'Save reminder'**
  String get promemoriaSave;

  /// No description provided for @promemoriaEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit reminder'**
  String get promemoriaEditTitle;

  /// No description provided for @promemoriaEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get promemoriaEdit;

  /// No description provided for @promemoriaSaveShort.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get promemoriaSaveShort;

  /// No description provided for @promemoriaDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get promemoriaDelete;

  /// No description provided for @promemoriaDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete reminder'**
  String get promemoriaDeleteTitle;

  /// No description provided for @promemoriaCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get promemoriaCancel;

  /// No description provided for @promemoriaDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the reminder?'**
  String get promemoriaDeleteConfirm;
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
