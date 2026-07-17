import 'entities/glossary_entry.dart';

/// Source of truth for the glossary terms and the tool's CMS copy.
abstract class GlossarioRepository {
  /// All glossary terms, alphabetical.
  Future<List<GlossaryEntry>> getEntries();

  /// The tool's CMS copy and its blocked flag.
  Future<GlossaryContent> getContent();
}
