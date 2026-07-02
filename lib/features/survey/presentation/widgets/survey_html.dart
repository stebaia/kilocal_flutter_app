import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../../../core/theme/app_colors.dart';

/// Renders CMS HTML copy (section title/subtitle/content) with brand styling.
///
/// The CMS wraps copy in tags like `<h1>`, `<p>`, `<strong>`. It also uses
/// `{{name}}`, `{{type}}`, `{{product}}` placeholders on result screens; pass
/// [placeholders] to substitute them.
class SurveyHtml extends StatelessWidget {
  const SurveyHtml({
    super.key,
    required this.html,
    this.baseFontSize = 16,
    this.color,
    this.bold = false,
    this.lineHeight = 1.2,
    this.placeholders = const {},
    this.highlightKeys = const {},
  });

  final String html;
  final double baseFontSize;
  final Color? color;
  final bool bold;
  final double lineHeight;
  final Map<String, String> placeholders;

  /// Placeholder keys whose substituted value is wrapped in the magenta
  /// [AppColors.typeHighlight] (e.g. `type` → "Tipo 4 - Pera").
  final Set<String> highlightKeys;

  @override
  Widget build(BuildContext context) {
    var content = html;
    placeholders.forEach((key, value) {
      final replacement = highlightKeys.contains(key)
          ? '<span class="hl">$value</span>'
          : value;
      content = content.replaceAll('{{$key}}', replacement);
    });
    // Drop any placeholders left unfilled so raw `{{...}}` never shows.
    content = content.replaceAll(RegExp(r'\{\{[^}]+\}\}'), '');

    return Html(
      data: content,
      style: {
        '*': Style(margin: Margins.zero, color: color ?? AppColors.textPrimary),
        'body': Style(
          fontSize: FontSize(baseFontSize),
          fontWeight: bold ? FontWeight.w800 : FontWeight.w400,
          lineHeight: LineHeight(lineHeight),
        ),
        'h1': Style(
          fontSize: FontSize(baseFontSize + 4),
          fontWeight: FontWeight.w800,
        ),
        'strong': Style(fontWeight: FontWeight.w700),
        'p': Style(margin: Margins.only(bottom: 8)),
        '.hl': Style(color: AppColors.typeHighlight),
      },
    );
  }
}
