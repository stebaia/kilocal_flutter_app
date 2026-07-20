import '../../../../core/config/env.dart';
import '../../../../core/network/graphql_client.dart';
import '../domain/entities/glossary_entry.dart';
import '../domain/glossario_repository.dart';

/// Reads the glossary over GraphQL — there is no REST endpoint for it.
///
/// The whole list (~100 terms) is fetched once and searched/filtered in memory:
/// the backend does support `_icontains`/`_istarts_with` filters, but at this
/// size a round trip per keystroke or per letter buys nothing.
/// Schema verified live; see [[glossario-schema]].
class GlossarioRepositoryImpl implements GlossarioRepository {
  GlossarioRepositoryImpl({required GraphqlClient graphql}) : _graphql = graphql;

  final GraphqlClient _graphql;

  /// `limit: -1` is required: Directus caps collections at 100 rows by default,
  /// which would silently drop more than half the glossary (226 terms live).
  ///
  /// `glossary` has no `sort` field despite what the app spec says, so ordering
  /// is done client-side.
  static const _entriesQuery = r'''
    query Glossary {
      glossary(limit: -1) {
        id
        translations(filter: { languages_code: { code: { _eq: "it-IT" } } }) {
          title
          content
        }
      }
    }
  ''';

  static const _contentQuery = r'''
    query GlossaryTool {
      glossary_tool {
        is_tool_blocked
        translations(filter: { languages_code: { code: { _eq: "it-IT" } } }) {
          title
          description
          search_bar_placeholder
        }
      }
    }
  ''';

  @override
  Future<List<GlossaryEntry>> getEntries() async {
    final body = await _graphql.query(_entriesQuery);
    final data = body['data'] as Map<String, dynamic>?;
    final rows = data?['glossary'] as List<dynamic>? ?? const [];

    final entries = rows
        .whereType<Map<String, dynamic>>()
        .map(_entryFromRow)
        .whereType<GlossaryEntry>()
        .toList();

    entries.sort(
      (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
    );
    return entries;
  }

  @override
  Future<GlossaryContent> getContent() async {
    final body = await _graphql.query(_contentQuery);
    final data = body['data'] as Map<String, dynamic>?;
    final tool = data?['glossary_tool'] as Map<String, dynamic>?;
    if (tool == null) return const GlossaryContent();

    final translations = tool['translations'] as List<dynamic>?;
    final t = translations?.whereType<Map<String, dynamic>>().firstOrNull;

    return GlossaryContent(
      // Staging ships the tool blocked; debug builds ignore the flag so it
      // stays testable, release always honours the CMS.
      isToolBlocked: Env.ignoreToolBlocked
          ? false
          : tool['is_tool_blocked'] as bool? ?? false,
      title: t?['title'] as String?,
      description: t?['description'] as String?,
      searchPlaceholder: t?['search_bar_placeholder'] as String?,
    );
  }

  /// Untranslated rows are skipped: with no title there is nothing to show or
  /// file under a letter.
  GlossaryEntry? _entryFromRow(Map<String, dynamic> row) {
    final translations = row['translations'] as List<dynamic>?;
    final t = translations?.whereType<Map<String, dynamic>>().firstOrNull;
    final title = (t?['title'] as String?)?.trim();
    if (title == null || title.isEmpty) return null;

    return GlossaryEntry(
      id: row['id']?.toString() ?? '',
      title: title,
      content: t?['content'] as String? ?? '',
    );
  }
}
