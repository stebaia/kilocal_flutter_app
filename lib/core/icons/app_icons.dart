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
  static const String playSmall = 'play_small';
  static const String chart = 'chart';
  static const String filter = 'filter';
  static const String training = 'training';
  static const String flash = 'flash';
  static const String food = 'food';
  static const String wellness = 'wellness';
  static const String lock = 'lock';
  static const String briefcase = 'briefcase';
  static const String archive = 'archive';
  static const String mindfulness = 'mindfulness';
  static const String selfCare = 'self_care';
  static const String lifestyle = 'lifestyle';
  static const String activities = 'activities';
  static const String strumenti = 'strumenti';
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
