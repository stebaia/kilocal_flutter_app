/// A product whose barcode can unlock the full programme for a restricted user.
///
/// Sourced from the `products` GraphQL collection filtered on
/// `use_for_barcode_check: true`. The [codes] set holds every valid barcode for
/// the product, including its variants' barcodes, normalised to upper case.
class BarcodeProduct {
  const BarcodeProduct({
    required this.id,
    required this.title,
    required this.codes,
  });

  final String id;

  /// Product display name (e.g. "Kilocal Brucia Grassi Urto"), shown in the
  /// unlock sheet copy.
  final String title;

  /// All accepted barcodes for this product (product + variants), upper-cased.
  final Set<String> codes;
}
