import 'entities/pharmacy.dart';
import 'entities/survey_answer.dart';
import 'entities/survey_outcome.dart';
import 'entities/survey_step.dart';

/// Read + write access to the survey/onboarding flow.
///
/// Reads (survey definition) go through GraphQL; writes (status, ensure-details,
/// submit) go through the `survey` REST extension. See `wiki/survey.md`.
abstract interface class SurveyRepository {
  /// Loads a survey definition by its CMS `internal_name` (e.g. `type_survey`).
  Future<Survey> fetchSurvey(String internalName);

  /// Current onboarding status (`GET /survey/me/status`).
  Future<SurveyStatusInfo> fetchStatus();

  /// Idempotently ensures the `user_details` row exists
  /// (`POST /survey/me/ensure-details`). Call early in onboarding.
  Future<void> ensureDetails();

  /// Pending month-end survey, or `null` if none
  /// (`GET /survey/me/month-end-status`).
  ///
  /// Has a **side-effect**: when a survey is pending the backend creates the
  /// matching `traguardo_mese_N` goal, so this must run before listing goals or
  /// the predefined Kilocal ones never show up.
  Future<SurveyMonthEndPending?> fetchMonthEndStatus();

  /// Searches the `pharmacies` collection (22k+ rows → server-side [search]).
  /// Used by the Kilocal Point picker in pharmacy onboarding.
  Future<List<Pharmacy>> searchPharmacies(String query, {int limit = 20});

  /// Submits the collected answers (`POST /survey/submit/{internalName}`).
  Future<SurveySubmitResult> submit({
    required String internalName,
    required List<SurveyAnswer> answers,
    required Survey survey,
    Pharmacy? pharmacy,
  });

  /// Hydrates the biotype [outcome] with its CMS copy from `profiles`.
  ///
  /// The submit response only references the profile by id, so the result
  /// screen's texts and images have to be read separately. [gender] selects
  /// between the `content` / `content_f` variants.
  Future<SurveyOutcome> fetchOutcomeProfile(
    SurveyOutcome outcome, {
    String? gender,
  });
}
