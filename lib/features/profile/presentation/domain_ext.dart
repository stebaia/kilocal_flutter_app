import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/entities/profile_kit.dart';

/// Presentation helpers for [ProfileKitCta]: turns a CTA into a tap callback
/// that opens its url in the external browser, or `null` when the CTA has no
/// usable destination (staging often leaves `url` empty), which disables the
/// button.
extension ProfileKitCtaLaunch on ProfileKitCta? {
  VoidCallback? launchable(BuildContext context) {
    final cta = this;
    if (cta == null || !cta.isActive) return null;
    return () async {
      final uri = Uri.tryParse(cta.url!);
      if (uri == null) return;
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    };
  }
}
