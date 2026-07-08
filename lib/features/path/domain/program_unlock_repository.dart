import 'entities/barcode_product.dart';

/// Contract for the restricted-user "unlock the full programme" flow.
///
/// Unlocking is a **client-side barcode check** (there is no dedicated unlock
/// endpoint): the app fetches the products flagged `use_for_barcode_check` and
/// validates the code the user typed against their barcodes. The final step —
/// persisting the unlock so `profile_status` leaves `active_restricted_access`
/// — is still open on the backend (see [[restricted-access-path-gating]]) and
/// is currently a stub in the implementation.
abstract class ProgramUnlockRepository {
  /// Fetches every product usable for the barcode check, with its accepted
  /// codes (product + variants). Used to validate the code entered in the
  /// unlock sheet.
  Future<List<BarcodeProduct>> fetchBarcodeProducts();

  /// Persists the unlock after a valid barcode match, lifting the user's
  /// restricted access.
  ///
  /// STUB: the backend contract for this is not yet defined. See
  /// [[restricted-access-path-gating]]. Throws [UnimplementedError] until the
  /// backend answers which field/mutation performs the unlock.
  Future<void> unlockWithProduct(BarcodeProduct product);
}
