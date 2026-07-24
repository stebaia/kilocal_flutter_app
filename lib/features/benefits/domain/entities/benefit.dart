/// Domain entity representing a single partner benefit.
class Benefit {
  const Benefit({
    required this.id,
    required this.name,
    required this.mainPartner,
    this.coupon,
    this.description,
    this.couponInstructions,
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

  /// Localized partner description, shown on the first step of the sheet.
  final String? description;

  /// Localized coupon copy ("use code X on site Y…"), shown on the second step
  /// after the user taps the reward CTA. Kept separate from [description] so
  /// the code is only revealed once the reward is claimed.
  final String? couponInstructions;

  /// Cover image (hero card), built from the `asset` file.
  final String? imageUrl;

  /// Logo (secondary list rows), built from the `logo` file.
  final String? logoUrl;

  /// External CTA url ("Visualizza dettagli").
  final String? ctaUrl;
}
