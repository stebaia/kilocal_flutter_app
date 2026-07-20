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
  String get onboardingStart => 'Let\'s start';

  @override
  String get onboardingSkip => 'Skip';

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
  String get registerBottomPrompt => 'Already have an account?';

  @override
  String get registerBottomLink => 'Sign in';

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
  String get forgotPasswordTitle => 'Recover password';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your account email. We\'ll send you a link to reset your password.';

  @override
  String get forgotPasswordButton => 'Send link';

  @override
  String get forgotPasswordBackPrompt => 'Remembered your password?';

  @override
  String get forgotPasswordBackLink => 'Sign in';

  @override
  String get forgotPasswordSuccessTitle => 'Check your email';

  @override
  String get forgotPasswordSuccessDescription =>
      'If the address is linked to an account, you\'ll receive a link to reset your password.';

  @override
  String get forgotPasswordErrorMissingEmail => 'Please enter your email.';

  @override
  String get forgotPasswordErrorBadRequest =>
      'Invalid email. Please check and try again.';

  @override
  String get forgotPasswordErrorNetwork =>
      'No connection. Please try again later.';

  @override
  String get forgotPasswordErrorServer =>
      'Server error. Please try again later.';

  @override
  String get forgotPasswordErrorGeneric =>
      'Something went wrong. Please try again.';

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
  String get pathLockedTitle => 'Locked content';

  @override
  String get pathLockedBody =>
      'This content is not available with your current plan. Buy your starter kit to unlock the full programme.';

  @override
  String get pathLockedUnderstood => 'Got it';

  @override
  String get pathLockedBoughtKit => 'I bought the Starter kit';

  @override
  String get pathUnlockTitle => 'Unlock the programme';

  @override
  String get pathUnlockInstructions =>
      'Enter the barcode printed on the pack of the Kilocal product you bought. The code is 1 letter followed by 9 digits.';

  @override
  String get pathUnlockCodeHint => 'Enter proof-of-purchase code…';

  @override
  String get pathUnlockSubmit => 'Submit';

  @override
  String get pathUnlockInvalidCode =>
      'This code doesn\'t match any Kilocal product. Check it and try again.';

  @override
  String get pathUnlockSuccess => 'Programme unlocked!';

  @override
  String get diaryTitle => 'Activity diary';

  @override
  String get benefitsTitle => 'Benefits';

  @override
  String get profileTitle => 'Your Profile';

  @override
  String get profileMyTypeSection => 'My Type';

  @override
  String get profileMyTypeValue => 'Type 4 - Pear';

  @override
  String get profileTypeUnknown => 'My Type';

  @override
  String get profileTypeCharacteristics => 'Your characteristics';

  @override
  String get profileTypeDiscoverMore => 'Discover more';

  @override
  String profileTypeStartingPoint(String type) {
    return '$type - Your starting point';
  }

  @override
  String get profileTypePathToFeelBest => 'The path to feel your best';

  @override
  String get profileTypePointTitleFallback => 'Body point';

  @override
  String get profileTypePointBodyFallback => 'Content coming soon.';

  @override
  String get profileTypeProductsSection => 'Product information';

  @override
  String get profileTypeMyKit => 'My Kit';

  @override
  String get profileTypeSupplements => 'Supplements and products';

  @override
  String profileKitTitle(String type) {
    return 'Kit $type';
  }

  @override
  String get profileKitBuy => 'Buy';

  @override
  String get profileKitEmpty => 'No products available.';

  @override
  String get profileCategorySection => 'Section category name';

  @override
  String get profilePersonalData => 'My personal data';

  @override
  String get profileMyAccount => 'My account';

  @override
  String get profileSaved => 'Changes saved';

  @override
  String get profileAvatarChange => 'Change profile photo';

  @override
  String get profileAvatarFromCamera => 'Take a photo';

  @override
  String get profileAvatarFromGallery => 'Choose from gallery';

  @override
  String get profileAvatarUpdated => 'Profile photo updated';

  @override
  String get profileAvatarError => 'Couldn\'t update the profile photo';

  @override
  String get profileChangePassword => 'Change password';

  @override
  String get profileChangePasswordHint =>
      'Choose a new password for your account.';

  @override
  String get profileNewPassword => 'New password';

  @override
  String get profileConfirmPassword => 'Confirm new password';

  @override
  String get profileChangePasswordSubmit => 'Update password';

  @override
  String get profilePasswordUpdated => 'Password updated';

  @override
  String get profilePasswordError => 'Couldn\'t update the password';

  @override
  String profilePasswordTooShort(int count) {
    return 'Password must be at least $count characters';
  }

  @override
  String get profilePasswordMismatch => 'The two passwords don\'t match';

  @override
  String get profileFoodPreferences => 'Food preferences';

  @override
  String get profileFoodPreferencesEdit => 'Add or edit';

  @override
  String get profileFoodPreferencesEmpty => 'No selection';

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
  String get profileAppVersionSection => 'App';

  @override
  String get profileAppVersion => 'App version';

  @override
  String profileAppVersionValue(String version) {
    return 'Version $version';
  }

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
  String get surveyFindPharmacy => 'Find a Kilocal Point pharmacy';

  @override
  String get surveyGoToShop => 'Go to the shop';

  @override
  String get surveyEnterProofOfPurchase => 'Enter proof of purchase';

  @override
  String get surveyErrorNotANumber => 'Enter a valid number';

  @override
  String get surveyErrorNotAnInteger => 'Enter a whole number';

  @override
  String get surveyErrorTooSmall => 'That value is too low';

  @override
  String get surveyErrorTooLarge => 'That value is too high';

  @override
  String get surveyErrorNotADate => 'Enter a valid date';

  @override
  String get surveyErrorDateTooLate => 'You must be at least 18';

  @override
  String get surveyErrorDateTooEarly => 'Enter a valid date';

  @override
  String get surveyErrorBmiTooLow =>
      'That weight is not compatible with your height';

  @override
  String get surveyErrorInvalidZipCode => 'Enter a valid postcode (5 digits)';

  @override
  String get surveyErrorInvalidPhone => 'Enter a valid phone number';

  @override
  String get surveyErrorInvalidBarcode =>
      'Barcode not recognised. Check the code on your Starter Kit pack.';

  @override
  String get surveyBarcodeChecking => 'Checking the code…';

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
  String get benefitClaimReward => 'Claim the reward';

  @override
  String get benefitClaimRewardError => 'Unable to open the reward link';

  @override
  String benefitVisitSite(String partner) {
    return 'Visit the $partner website';
  }

  @override
  String get benefitCouponCopied => 'Discount code copied';

  @override
  String get benefitsEmpty => 'No benefits available';

  @override
  String get momentiTitle => 'Moments';

  @override
  String get momentiEmpty => 'No moments available';

  @override
  String get momentiInfoTitle => 'Information';

  @override
  String get momentiInfoTooltip => 'Information about this moment';

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
  String get integrationCurrentPhase => 'Current phase';

  @override
  String get integrationNotStarted => 'Not started yet';

  @override
  String get integrationPhasesTitle => 'Your plan';

  @override
  String get integrationEmpty => 'No supplement plan available.';

  @override
  String integrationProductDuration(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String integrationProductQuantity(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count per day',
      one: '1 per day',
    );
    return '$_temp0';
  }

  @override
  String integrationPhaseLabel(int number) {
    return 'Phase $number';
  }

  @override
  String integrationCompletePhaseFirst(int number) {
    return 'Complete phase $number first';
  }

  @override
  String integrationPhaseTitle(int number) {
    return 'Integration Phase $number';
  }

  @override
  String integrationMonitoringWeeks(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: '$weeks weeks tracking',
      one: '1 week tracking',
    );
    return '$_temp0';
  }

  @override
  String integrationMonitoringDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days tracking',
      one: '1 day tracking',
    );
    return '$_temp0';
  }

  @override
  String get integrationMarkTaken => 'Mark supplement as taken';

  @override
  String get integrationMarkTakenError =>
      'Couldn\'t record the intake. Try again later.';

  @override
  String get integrationMarkedTaken => 'Intake recorded';

  @override
  String get integrationInstructionsTitle => 'Usage instructions';

  @override
  String get integrationStartDate => 'Start date:';

  @override
  String get integrationExpectedEndDate => 'Expected end date:';

  @override
  String get integrationEnableReminder => 'Enable reminder';

  @override
  String integrationReminderActiveLabel(String label) {
    return 'Reminder active: $label';
  }

  @override
  String get integrationReminderSnooze2hShort => 'snooze 2 hours';

  @override
  String get integrationReminderSnooze4hShort => 'snooze 4 hours';

  @override
  String get integrationReminderSnooze8hShort => 'snooze 8 hours';

  @override
  String get integrationReminderSnooze1dShort => 'snooze 1 day';

  @override
  String get integrationReminderEnabled => 'Reminder enabled';

  @override
  String get integrationReminderError =>
      'Couldn\'t enable the reminder. Check your notification permissions.';

  @override
  String get integrationReminderAddTitle => 'Add reminder';

  @override
  String get integrationReminderEditDeleteTitle => 'Edit or delete reminder';

  @override
  String get integrationReminderEditTitle => 'Edit reminder';

  @override
  String get integrationReminderSelectTime => 'Select time';

  @override
  String get integrationReminderConfirm => 'Confirm';

  @override
  String get integrationReminderSave => 'Save';

  @override
  String get integrationReminderCancel => 'Cancel';

  @override
  String get integrationReminderEdit => 'Edit';

  @override
  String get integrationReminderDelete => 'Delete';

  @override
  String get integrationReminderDeleteConfirm =>
      'Are you sure you want to delete this reminder?';

  @override
  String get integrationReminderDeleted => 'Reminder deleted';

  @override
  String integrationReminderMessage(String product) {
    return 'Take the product \"$product\". This message is generated automatically.';
  }

  @override
  String integrationReminderSnoozedLabel(String label) {
    return 'Snoozed by $label';
  }

  @override
  String get integrationReminderSnooze2h => 'Snooze 2 hours';

  @override
  String get integrationReminderSnooze4h => 'Snooze 4 hours';

  @override
  String get integrationReminderSnooze8h => 'Snooze 8 hours';

  @override
  String get integrationReminderSnooze1d => 'Snooze 1 day';

  @override
  String get diaryTabHistory => 'History';

  @override
  String get diaryTabGoals => 'Goals';

  @override
  String get diaryHistoryEmpty => 'No activity recorded yet.';

  @override
  String get diaryGoalsEmpty => 'You don\'t have any goals yet.';

  @override
  String get diaryGoalPersonal => 'Personal';

  @override
  String get diaryGoalKilocal => 'Kilocal';

  @override
  String get diaryGoalCompleted => 'Achieved';

  @override
  String get diaryFilterAll => 'All goals';

  @override
  String get diaryFilterPersonal => 'Personal goals';

  @override
  String get diaryFilterKilocal => 'Kilocal goals';

  @override
  String get diaryFilterCompleted => 'Completed';

  @override
  String get diaryGoalCreateTitle => 'New goal';

  @override
  String get diaryGoalContentHint => 'Describe your goal';

  @override
  String get diaryGoalCategory => 'Category';

  @override
  String get diaryGoalPickDate => 'Add a date';

  @override
  String get diaryGoalSave => 'Save';

  @override
  String get diaryActivityDetailTitle => 'Activity details';

  @override
  String diaryActivityCategory(String category) {
    return 'Category: $category';
  }

  @override
  String diaryActivityPlannedOn(String date) {
    return 'Planned completion: $date';
  }

  @override
  String diaryActivityToComplete(String date) {
    return 'To complete: $date';
  }

  @override
  String get diaryActivityCompleteError =>
      'Couldn\'t complete the activity. Try again.';

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
  String get pathTimerStop => 'stop';

  @override
  String get pathTimerPause => 'Pause';

  @override
  String get pathTimerResume => 'Resume';

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
  String get pathMaterialDownloadError =>
      'Could not open the file. Please try again.';

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

  @override
  String get strumentiTitle => 'Tools';

  @override
  String get strumentiLaunch => 'Launch tool';

  @override
  String get strumentiPromemoria => 'Reminders';

  @override
  String get strumentiTimer => 'Timer';

  @override
  String get strumentiGlossario => 'Glossary';

  @override
  String get strumentiGallery => 'Gallery';

  @override
  String get strumentiComingSoon => 'This tool will be available soon.';

  @override
  String get glossarioSearch => 'Search';

  @override
  String get glossarioSearchHint => 'Keyword';

  @override
  String get glossarioResults => 'Matching results';

  @override
  String get glossarioEmpty => 'No results for this search.';

  @override
  String get glossarioLoadError => 'Could not load the glossary.';

  @override
  String get galleryPhotosTitle => 'My photos';

  @override
  String get galleryUploadTitle => 'Upload image';

  @override
  String get galleryUploadInfo =>
      'Use the button to upload content from your device';

  @override
  String get galleryUpload => 'Upload';

  @override
  String get galleryTakePhoto => 'Take photo';

  @override
  String get galleryRetakePhoto => 'Retake';

  @override
  String get galleryConfirmUpload => 'Confirm and upload';

  @override
  String get galleryUploadError => 'Could not upload the photo. Try again.';

  @override
  String get galleryDeleteError => 'Could not delete the photo. Try again.';

  @override
  String get galleryLoadError => 'Could not load your photos.';

  @override
  String get galleryEmpty => 'You haven\'t uploaded any photos yet.';

  @override
  String get galleryToolBlocked => 'This tool is not available right now.';

  @override
  String get galleryDelete => 'Delete';

  @override
  String get galleryCancel => 'Cancel';

  @override
  String get gallerySplitTitle => 'Split image';

  @override
  String get gallerySave => 'Save';

  @override
  String get galleryShare => 'Share';

  @override
  String get gallerySaved => 'Image saved';

  @override
  String get gallerySaveError => 'Could not save the image.';

  @override
  String get promemoriaViewList => 'List';

  @override
  String get promemoriaViewCalendar => 'Calendar';

  @override
  String get promemoriaEmpty => 'No reminders for this month.';

  @override
  String get promemoriaLoadError => 'Couldn\'t load reminders.';

  @override
  String get promemoriaAddTitle => 'Add reminder';

  @override
  String get promemoriaMessageLabel => 'Message';

  @override
  String get promemoriaMessageHint => 'Enter the reminder text here';

  @override
  String get promemoriaDateLabel => 'Date';

  @override
  String get promemoriaTimeLabel => 'Time';

  @override
  String get promemoriaSelectDate => 'Select date';

  @override
  String get promemoriaSelectTime => 'Select time';

  @override
  String get promemoriaConfirm => 'Confirm';

  @override
  String get promemoriaSave => 'Save reminder';

  @override
  String get promemoriaEditTitle => 'Edit reminder';

  @override
  String get promemoriaEdit => 'Edit';

  @override
  String get promemoriaSaveShort => 'Save';

  @override
  String get promemoriaDelete => 'Delete';

  @override
  String get promemoriaDeleteTitle => 'Delete reminder';

  @override
  String get promemoriaCancel => 'Cancel';

  @override
  String get promemoriaDeleteConfirm =>
      'Are you sure you want to delete the reminder?';
}
