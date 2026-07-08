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
  /// Backend contract (confirmed 2026-07-08): `PATCH /profile` with
  /// `{ "has_kit_purchased": true, "profile_status": "starter_kit" }`.
  /// The BE enforces a state machine: from `active_restricted_access` the PATCH
  /// only accepts `→ starter_kit` (jumping to `active` is rejected with
  /// `INVALID_PAYLOAD`). The user then reaches `active` by completing the
  /// starter-kit survey. (`initial_survey` is avoided: it reopens the biotype
  /// quiz and crashes the CMS result template for a user who already has one.)
  Future<void> unlockWithProduct(BarcodeProduct product);
}
