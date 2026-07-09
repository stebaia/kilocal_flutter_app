import 'entities/barcode_product.dart';

/// Contract for the restricted-user "unlock the full programme" flow.
///
/// Unlocking is a **client-side barcode check** (there is no dedicated unlock
/// endpoint): the app fetches the products flagged `use_for_barcode_check` and
/// validates the code the user typed against their barcodes. On a match the
/// unlock is persisted by moving `profile_status` off `active_restricted_access`
/// via `PATCH /profile` (see [[restricted-access-path-gating]]).
abstract class ProgramUnlockRepository {
  /// Fetches every product usable for the barcode check, with its accepted
  /// codes (product + variants). Used to validate the code entered in the
  /// unlock sheet.
  Future<List<BarcodeProduct>> fetchBarcodeProducts();

  /// Persists the unlock after a valid barcode match, lifting the user's
  /// restricted access.
  ///
  /// Backend contract (confirmed 2026-07-09): `PATCH /profile` with
  /// `{ "has_kit_purchased": true, "profile_status": "active" }`. A restricted
  /// user who unlocks with the purchase barcode has already completed
  /// `type_survey` (biotype) and the `sp-kilocal` questionnaire, so the BE now
  /// allows the direct jump to `active` — no surveys are replayed.
  /// (Previously the state machine rejected `→ active` with `INVALID_PAYLOAD`,
  /// forcing a detour through `starter_kit`/`initial_survey`; unblocked on staging.)
  Future<void> unlockWithProduct(BarcodeProduct product);
}
