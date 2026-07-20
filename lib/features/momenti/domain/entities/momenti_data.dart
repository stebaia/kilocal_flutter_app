/// A single editorial "Momento" — title + rich-text description + hero image.
///
/// The CMS only exposes structured `title` / `description` for a moment; the
/// "Meccanica" block visible in the design lives inside the [description] HTML,
/// so it is not modelled as a separate field.
class MomentiData {
  const MomentiData({
    required this.title,
    required this.description,
    this.plot,
    this.heroImageUrl,
  });

  final String title;

  /// Rich-text body (HTML) returned by the CMS. Rendered with `flutter_html`.
  final String description;

  /// Short plain-text abstract, or `null` when the CMS leaves it empty. Shown
  /// in the header info sheet; the header hides the info action without it.
  final String? plot;

  /// Absolute URL of the hero asset, or `null` when the moment has no image.
  final String? heroImageUrl;
}
