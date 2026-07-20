import '../../../l10n/app_localizations.dart';
import '../domain/survey_validation.dart';

/// Localized copy for an `other_validations` failure.
///
/// The CMS carries no error messages of its own, so the wording lives in the
/// ARB files alongside the rest of the survey UI.
extension SurveyValidationErrorL10n on SurveyValidationError {
  String message(AppLocalizations l10n) {
    switch (this) {
      case SurveyValidationError.notANumber:
        return l10n.surveyErrorNotANumber;
      case SurveyValidationError.notAnInteger:
        return l10n.surveyErrorNotAnInteger;
      case SurveyValidationError.tooSmall:
        return l10n.surveyErrorTooSmall;
      case SurveyValidationError.tooLarge:
        return l10n.surveyErrorTooLarge;
      case SurveyValidationError.notADate:
        return l10n.surveyErrorNotADate;
      case SurveyValidationError.dateTooLate:
        return l10n.surveyErrorDateTooLate;
      case SurveyValidationError.dateTooEarly:
        return l10n.surveyErrorDateTooEarly;
      case SurveyValidationError.bmiTooLow:
        return l10n.surveyErrorBmiTooLow;
      case SurveyValidationError.invalidZipCode:
        return l10n.surveyErrorInvalidZipCode;
      case SurveyValidationError.invalidPhone:
        return l10n.surveyErrorInvalidPhone;
    }
  }
}
