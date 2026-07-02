import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/graphql_client.dart';
import '../domain/entities/profile_page.dart';
import '../domain/profile_page_repository.dart';
import 'cms_form_mapper.dart';

/// GraphQL-backed [ProfilePageRepository] over Directus `private_pages`.
///
/// `sections` is a M2A relation; the app expands the known block types with
/// inline fragments and maps unknown collections to
/// [ProfilePageUnknownSection]. See [[profile-cms-pages-schema]].
class ProfilePageRepositoryImpl implements ProfilePageRepository {
  ProfilePageRepositoryImpl({required GraphqlClient graphqlClient})
    : _graphqlClient = graphqlClient;

  final GraphqlClient _graphqlClient;

  // The CMS uses codes like "it-IT" / "en-US". Default to Italian for now,
  // matching the other repositories.
  static const _lang = 'it-IT';

  static const _query = r'''
query GetPrivatePageByInternalName($internalName: String!, $lang: String!) {
  private_pages(filter: { internal_name: { _eq: $internalName } }, limit: 1) {
    id
    internal_name
    is_page_blocked
    sections {
      collection
      item {
        __typename
        ... on private_page_type {
          translations(filter: { languages_code: { code: { _eq: $lang } } }) {
            title
          }
        }
        ... on private_sec_percorsi {
          layout
          translations(filter: { languages_code: { code: { _eq: $lang } } }) {
            title
          }
        }
        ... on private_sec_profile {
          tabs {
            private_sec_profile_tabs_id {
              id
              translations(filter: { languages_code: { code: { _eq: $lang } } }) {
                title
              }
              form {
                id
                internal_name
                submit_path
                fields {
                  form_schema_entry_id {
                    key
                    name
                    validation
                    schema
                    translations(
                      filter: { languages_code: { code: { _eq: $lang } } }
                    ) {
                      label
                      placeholder
                      validation_label
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
''';

  @override
  Future<ProfilePage> fetchPage(String internalName) async {
    try {
      final result = await _graphqlClient.query(
        _query,
        variables: <String, dynamic>{
          'internalName': internalName,
          'lang': _lang,
        },
      );

      final data = result['data'] as Map<String, dynamic>?;
      final pages = data?['private_pages'] as List<dynamic>?;
      if (pages == null || pages.isEmpty) {
        throw ApiException(
          type: ApiErrorType.notFound,
          statusCode: 404,
          message: 'private_pages "$internalName" not found',
        );
      }

      return _mapPage(pages.first as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  ProfilePage _mapPage(Map<String, dynamic> json) {
    final rawSections = json['sections'] as List<dynamic>? ?? const [];
    final sections = rawSections
        .map((e) => _mapSection(e as Map<String, dynamic>))
        .whereType<ProfilePageSection>()
        .toList();

    return ProfilePage(
      internalName: json['internal_name'] as String? ?? '',
      isBlocked: json['is_page_blocked'] as bool? ?? false,
      sections: sections,
    );
  }

  ProfilePageSection? _mapSection(Map<String, dynamic> section) {
    final collection = section['collection'] as String?;
    final item = section['item'] as Map<String, dynamic>?;
    if (collection == null) return null;

    switch (collection) {
      case 'private_page_type':
        return ProfilePageTitleSection(title: _firstTitle(item) ?? '');
      case 'private_sec_percorsi':
        return ProfilePagePercorsiSection(
          intro: _firstTitle(item),
          layout: item?['layout'] as String?,
        );
      case 'private_sec_profile':
        return _mapFormTabs(item);
      default:
        return ProfilePageUnknownSection(collection: collection);
    }
  }

  ProfilePageFormTabsSection _mapFormTabs(Map<String, dynamic>? item) {
    final rawTabs = item?['tabs'] as List<dynamic>? ?? const [];
    final tabs = <ProfileFormTab>[];
    for (final raw in rawTabs) {
      final junction = raw as Map<String, dynamic>;
      final tab =
          junction['private_sec_profile_tabs_id'] as Map<String, dynamic>?;
      if (tab == null) continue;

      final formJson = tab['form'] as Map<String, dynamic>?;
      tabs.add(
        ProfileFormTab(
          id: tab['id']?.toString() ?? '',
          title: _firstTitle(tab) ?? '',
          form: formJson == null ? null : mapCmsForm(formJson),
        ),
      );
    }
    return ProfilePageFormTabsSection(tabs: tabs);
  }

  /// Reads `translations[0].title` from a block item, if present.
  String? _firstTitle(Map<String, dynamic>? item) {
    final translations = item?['translations'] as List<dynamic>?;
    final first = translations?.isNotEmpty ?? false
        ? translations!.first as Map<String, dynamic>
        : null;
    return first?['title'] as String?;
  }
}
