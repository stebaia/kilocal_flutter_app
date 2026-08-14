import '../config/env.dart';

/// Rendering widths for CMS images, in logical pixels.
///
/// Directus resizes server-side, so requesting a width close to the widget's
/// actual size avoids shipping a 4096px original for a 150px thumbnail. The
/// CMS library averages 840 KB per image (a third of it over 500 KB, the
/// worst 27 MB), which is what made covers take seconds to appear.
enum CmsImageSize {
  /// Small square-ish images: avatars, list logos, biotype icons (~44-80px).
  thumb(160),

  /// List and grid cards, gallery tiles (~150-200px wide).
  card(400),

  /// Hero images and full-width covers on a detail screen.
  hero(800),

  /// Images shown at full screen width, where detail matters.
  full(1200);

  const CmsImageSize(this.width);

  /// Requested width in logical pixels, before the device pixel ratio.
  final int width;
}

/// Builds a `{baseUrl}/assets/{id}` URL with server-side resizing.
///
/// [width] is in *logical* pixels and is multiplied by [pixelRatio] so the
/// image stays sharp on high-density screens; the result is capped at
/// [maxPhysicalWidth] to stop a 3x phone from requesting a needlessly large
/// render.
///
/// [filename] is appended when present — Directus serves an asset by id alone,
/// and several endpoints return files without a `filename_download` (see
/// [[cms-asset-url-pattern]]). It is percent-encoded because CMS file names
/// contain spaces.
///
/// Returns `null` when [id] is `null` or empty, so callers can keep using the
/// null-aware mapping they already had.
///
/// Uses `fit=inside` with `withoutEnlargement`, never `fit=cover`: `cover`
/// upscales originals that are already smaller than the requested width, which
/// made a 3 KB logo come back as 30 KB. `inside` preserves the aspect ratio
/// rather than cropping, which is what the widgets want anyway — they all
/// apply `BoxFit.cover` themselves.
///
/// SVGs are passed through untouched by Directus even with these parameters,
/// so CMS icons keep their vector form.
///
/// Note: Directus rejects transformations on very large originals with
/// `ILLEGAL_ASSET_TRANSFORMATION` (observed above ~6000px, 47 files at time of
/// writing). Those assets must be re-uploaded smaller in the CMS; until then
/// the CMS answers with an error and the widgets show their usual placeholder.
String? cmsImageUrl(
  String? id, {
  required CmsImageSize size,
  String? filename,
  double pixelRatio = 1.0,
  int maxPhysicalWidth = 1600,
}) {
  if (id == null || id.isEmpty) return null;

  final physical = (size.width * pixelRatio).round().clamp(1, maxPhysicalWidth);

  final path = (filename == null || filename.isEmpty)
      ? '/assets/$id'
      : '/assets/$id/${Uri.encodeComponent(filename)}';

  return '${Env.baseUrl}$path'
      '?width=$physical'
      '&format=webp'
      '&quality=80'
      '&fit=inside'
      '&withoutEnlargement=true';
}

/// Builds a plain `{baseUrl}/assets/{id}` URL with no image transformation.
///
/// Use for non-image assets — PDFs, videos, SVG icons — where the resize
/// parameters are meaningless and, for SVG, would rasterise the file.
String? cmsFileUrl(String? id, {String? filename}) {
  if (id == null || id.isEmpty) return null;
  if (filename == null || filename.isEmpty) return '${Env.baseUrl}/assets/$id';
  return '${Env.baseUrl}/assets/$id/${Uri.encodeComponent(filename)}';
}
