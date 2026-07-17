import 'package:equatable/equatable.dart';

/// One glossary term (`glossary` row).
class GlossaryEntry extends Equatable {
  const GlossaryEntry({
    required this.id,
    required this.title,
    required this.content,
  });

  final String id;

  /// Display term, e.g. "Foam roller".
  final String title;

  /// Definition, as HTML.
  final String content;

  /// The letter this term files under in the A-Z index.
  String get initial => title.isEmpty ? '' : title[0].toUpperCase();

  @override
  List<Object?> get props => [id, title, content];
}

/// Static copy for the tool, from the `glossary_tool` CMS singleton.
class GlossaryContent extends Equatable {
  const GlossaryContent({
    this.title,
    this.description,
    this.searchPlaceholder,
    this.isToolBlocked = false,
  });

  final String? title;

  /// HTML.
  final String? description;
  final String? searchPlaceholder;

  /// CMS kill-switch for the whole tool.
  final bool isToolBlocked;

  @override
  List<Object?> get props => [
    title,
    description,
    searchPlaceholder,
    isToolBlocked,
  ];
}
