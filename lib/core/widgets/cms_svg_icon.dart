import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders a remote SVG icon served by the CMS (`{baseUrl}/assets/{id}`),
/// optionally tinted with [color].
///
/// Falls back to [fallback] (or an empty box) while loading or on error, so a
/// missing/failed icon never breaks the layout. Used for dynamic icons such as
/// the user's biotype icon (`profiles.icon`).
class CmsSvgIcon extends StatelessWidget {
  const CmsSvgIcon({
    super.key,
    required this.url,
    this.size = 24,
    this.color,
    this.fallback,
  });

  /// Full icon URL, or `null` to render only the [fallback].
  final String? url;
  final double size;
  final Color? color;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return _fallbackBox();
    }

    return SvgPicture.network(
      url!,
      width: size,
      height: size,
      colorFilter: color == null
          ? null
          : ColorFilter.mode(color!, BlendMode.srcIn),
      placeholderBuilder: (_) => _fallbackBox(),
    );
  }

  Widget _fallbackBox() => fallback ?? SizedBox(width: size, height: size);
}
