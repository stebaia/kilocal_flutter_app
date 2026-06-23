/// Domain entity representing a single partner benefit.
class Benefit {
  const Benefit({
    required this.id,
    required this.name,
    required this.mainPartner,
    this.coupon,
    this.description,
    this.imageUrl,
    this.logoUrl,
    this.ctaUrl,
  });

  final String id;
  final String name;

  /// Hero partner (shown in the "Primari" section) vs secondary list.
  final bool mainPartner;

  /// Discount code, when present.
  final String? coupon;

  /// Localized description / coupon instructions.
  final String? description;

  /// Cover image (hero card), built from the `asset` file.
  final String? imageUrl;

  /// Logo (secondary list rows), built from the `logo` file.
  final String? logoUrl;

  /// External CTA url ("Visualizza dettagli").
  final String? ctaUrl;
}
