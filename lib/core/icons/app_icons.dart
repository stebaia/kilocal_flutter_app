import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Nomi degli asset SVG presenti in [assets/icons].
abstract final class AppIcons {
  static const String home = 'home';
  static const String path = 'path';
  static const String diary = 'diary';
  static const String benefits = 'benefits';
  static const String popsicle = 'popsicle';
  static const String play = 'play';
  static const String chart = 'chart';
  static const String filter = 'filter';
}

/// Widget generico per le icone SVG dell'app.
class AppIcon extends StatelessWidget {
  final String name;
  final double? size;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit fit;

  const AppIcon(
    this.name, {
    this.size,
    this.width,
    this.height,
    this.color,
    this.fit = BoxFit.contain,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSize = size ?? 24;
    return SvgPicture.asset(
      'assets/icons/$name.svg',
      width: width ?? effectiveSize,
      height: height ?? effectiveSize,
      fit: fit,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
  }
}
