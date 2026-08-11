import '../../path/domain/entities/barcode_product.dart';
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
  /// Has a **side-effect**: it runs the goals *reconcile* — materialising the
  /// Kilocal goals the user has unlocked and auto-completing the per-area ones
  /// that reached 100%. `GET /journal/goals` reconciles too, so this isn't the
  /// only way the goals appear; see `wiki/diario.md`.
  ///
  /// A survey is reported pending only when allenamento + alimentazione +
  /// integrazione are all at 100% for the month (benessere doesn't count).
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

  /// Every product belonging to kit [kitId] (flattened across its phases),
  /// with its accepted barcodes (product + variants).
  ///
  /// Used for the proof-of-purchase step when the survey is about a Starter
  /// Kit rather than a single product (`single_product_barcode_check == false`
  /// on the section): the title shown in `Inserisci il codice a barre di:
  /// "{{product}}"` is picked at random from the user's own kit, and its
  /// barcodes replace the generic `use_for_barcode_check` catalogue for
  /// validating the code entered on this step.
  Future<List<BarcodeProduct>> fetchKitBarcodeProducts(String kitId);

  /// CMS copy for the confirmation dialog shown when an `#alert#`-marked
  /// option is selected (`alert_survey_risky_selection_modal`).
  ///
  /// Returns `null` when the CMS entity is missing, so the caller degrades to
  /// letting the user through unblocked rather than stalling on a dialog with
  /// no copy.
  Future<SurveyAlertModal?> fetchAlertModal();
}
