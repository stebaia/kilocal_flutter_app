part of 'glossario_cubit.dart';

enum GlossarioStatus { initial, loading, loaded, error }

class GlossarioState extends Equatable {
  const GlossarioState({
    this.status = GlossarioStatus.initial,
    this.entries = const [],
    this.content = const GlossaryContent(),
    this.letter,
    this.query = '',
    this.expandedId,
  });

  final GlossarioStatus status;

  /// Every term, alphabetical.
  final List<GlossaryEntry> entries;
  final GlossaryContent content;

  /// Selected A-Z letter, or null when the search box drives the results.
  final String? letter;

  /// Submitted search keyword ('' when not searching).
  final String query;

  /// Id of the open accordion; only one is expanded at a time.
  final String? expandedId;

  /// A search wins over the letter filter: typing a keyword should be able to
  /// reach terms under any letter.
  List<GlossaryEntry> get results {
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      return entries.where((e) => e.title.toLowerCase().contains(q)).toList();
    }
    if (letter != null) {
      return entries.where((e) => e.initial == letter).toList();
    }
    return entries;
  }

  GlossarioState copyWith({
    GlossarioStatus? status,
    List<GlossaryEntry>? entries,
    GlossaryContent? content,
    String? letter,
    bool clearLetter = false,
    String? query,
    String? expandedId,
    bool clearExpanded = false,
  }) {
    return GlossarioState(
      status: status ?? this.status,
      entries: entries ?? this.entries,
      content: content ?? this.content,
      letter: clearLetter ? null : (letter ?? this.letter),
      query: query ?? this.query,
      expandedId: clearExpanded ? null : (expandedId ?? this.expandedId),
    );
  }

  @override
  List<Object?> get props => [
    status,
    entries,
    content,
    letter,
    query,
    expandedId,
  ];
}
