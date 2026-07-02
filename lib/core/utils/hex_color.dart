import 'package:flutter/painting.dart';

/// Parses a CMS hex color string (e.g. `#E6007E` or `E6007E`, with optional
/// alpha) into a [Color], or `null` when [hex] is missing or malformed.
Color? colorFromHex(String? hex) {
  if (hex == null) return null;
  var value = hex.trim().replaceFirst('#', '');
  if (value.length == 6) value = 'FF$value';
  if (value.length != 8) return null;
  final parsed = int.tryParse(value, radix: 16);
  return parsed == null ? null : Color(parsed);
}
