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
  /// This clears `active_restricted_access` and routes the user into the
  /// post-purchase `starter_kit` survey. (`initial_survey` is avoided on
  /// purpose: it reopens the biotype quiz and crashes the CMS result template
  /// for a user who already has a biotype.)
  Future<void> unlockWithProduct(BarcodeProduct product);
}
