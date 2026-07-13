import 'package:equatable/equatable.dart';

/// Domain entities for the "Il mio Kit" / "Integrazione e prodotti" screens
/// opened from the two product cards on the biotype detail screen.
///
/// The kit assigned to the user's profile (`profiles.kit` → `product_kits`)
/// carries the plan copy ("Piano Lipolisi…"), its image and a "buy" CTA, plus an
/// ordered list of phases whose products are the individual supplement cards
/// (Kilocal Slim Cell, Brucia Grassi Urto, …). See [[integrazione-schema]].
class ProfileKit extends Equatable {
  const ProfileKit({
    required this.id,
    this.typeLabel,
    this.planTitle,
    this.description,
    this.imageUrl,
    this.price,
    this.cta,
    this.products = const [],
  });

  final String id;

  /// The kit type label, e.g. "Tipo 4" (`product_kits_translations.tipo_kit`),
  /// used for the "Kit tipo 4" header.
  final String? typeLabel;

  /// The plan title shown on the kit card (falls back to [typeLabel]).
  final String? planTitle;

  /// HTML plan description (`product_kits_translations.description`).
  final String? description;

  /// Full URL of the kit image (`asset.default_asset`).
  final String? imageUrl;

  final double? price;

  /// The "Acquista"/"Scopri di più" call-to-action, if the CMS provides a link.
  final ProfileKitCta? cta;

  /// The kit's supplement products, flattened across all phases in order.
  final List<ProfileKitProduct> products;

  @override
  List<Object?> get props => [
    id,
    typeLabel,
    planTitle,
    description,
    imageUrl,
    price,
    cta,
    products,
  ];
}

/// A single supplement product of the kit (Kilocal Slim Cell, Donna, …), shown
/// as a filterable card on the "Integrazione e prodotti" screen.
class ProfileKitProduct extends Equatable {
  const ProfileKitProduct({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.price,
    this.cta,
  });

  final String id;
  final String title;

  /// HTML long description ("Come agisce…") from `products_translations`.
  final String? description;

  /// Full URL of the product image (`asset.default_asset`).
  final String? imageUrl;

  final double? price;

  /// The product's "buy" CTA, if any.
  final ProfileKitCta? cta;

  @override
  List<Object?> get props => [id, title, description, imageUrl, price, cta];
}

/// A call-to-action link (`links` → `links_translations`). [url] is often null
/// in staging (content not filled in yet); the button is disabled when so.
class ProfileKitCta extends Equatable {
  const ProfileKitCta({required this.label, this.url});

  final String label;
  final String? url;

  /// Whether the CTA has a usable destination.
  bool get isActive => url != null && url!.isNotEmpty;

  @override
  List<Object?> get props => [label, url];
}
