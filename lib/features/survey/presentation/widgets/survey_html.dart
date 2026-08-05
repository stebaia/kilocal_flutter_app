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
    this.emphasisKeys = const {},
    this.highlightColor,
  });

  final String html;
  final double baseFontSize;
  final Color? color;
  final bool bold;
  final double lineHeight;
  final Map<String, String> placeholders;

  /// Placeholder keys whose substituted value is wrapped in [highlightColor]
  /// (e.g. `type` → "Tipo 4 - Pera").
  final Set<String> highlightKeys;

  /// Color for [highlightKeys] matches. Defaults to the brand magenta
  /// [AppColors.typeHighlight]; the result screen overrides it with the
  /// biotype's own CMS color so the header text matches the Kit card.
  final Color? highlightColor;

  /// Placeholder keys whose substituted value is emphasised as a lead-in
  /// paragraph (heavier weight, darker ink). Used for `outcome_profile`, whose
  /// personalized copy would otherwise blend into the legal disclaimer that
  /// follows it in the same CMS field.
  final Set<String> emphasisKeys;

  @override
  Widget build(BuildContext context) {
    var content = html;
    placeholders.forEach((key, value) {
      var replacement = value;
      if (highlightKeys.contains(key)) {
        replacement = '<span class="hl">$replacement</span>';
      }
      if (emphasisKeys.contains(key)) {
        replacement = '<span class="lead">$replacement</span>';
      }
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
        '.hl': Style(color: highlightColor ?? AppColors.typeHighlight),
        '.lead': Style(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      },
    );
  }
}
