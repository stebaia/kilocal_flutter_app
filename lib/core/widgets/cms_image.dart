import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// A remote image backed by an on-disk cache.
///
/// Wraps [CachedNetworkImage] so the app does not use [Image.network], which
/// only caches decoded frames in memory: that cache is dropped on every
/// restart, so covers were re-downloaded each time the app was reopened even
/// though the CMS already serves `cache-control: public, max-age=2592000`.
///
/// The parameters mirror [Image.network] (`errorBuilder`, `fit`, …) rather
/// than [CachedNetworkImage]'s own naming, so call sites read the same as the
/// widgets they replaced.
class CmsImage extends StatelessWidget {
  const CmsImage(
    this.url, {
    super.key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.alignment = Alignment.center,
    this.errorBuilder,
    this.placeholder,
    this.headers,
  });

  /// Absolute image url. Build it with `cmsImageUrl` so the CMS resizes it
  /// server-side instead of shipping the original.
  final String url;

  final BoxFit fit;
  final double? width;
  final double? height;
  final Alignment alignment;

  /// Shown when the image fails to load — including the CMS refusing to
  /// transform an oversized original.
  final WidgetBuilder? errorBuilder;

  /// Shown while the image is being fetched. Defaults to no placeholder, which
  /// keeps a cached image from flashing a spinner on rebuild.
  final WidgetBuilder? placeholder;

  /// Extra request headers. Needed for the user avatar, which Directus serves
  /// only to an authenticated request.
  final Map<String, String>? headers;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      width: width,
      height: height,
      alignment: alignment,
      httpHeaders: headers,
      // `memCacheWidth` is deliberately not set: the url already asks the CMS
      // for a right-sized render, so decoding it again would only cost time.
      errorWidget: errorBuilder == null
          ? null
          : (context, _, _) => errorBuilder!(context),
      placeholder: placeholder == null
          ? null
          : (context, _) => placeholder!(context),
    );
  }
}
