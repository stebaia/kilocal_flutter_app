import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kilocal_flutter_app/core/network/graphql_client.dart';
import 'package:kilocal_flutter_app/features/path/data/path_materials_repository_impl.dart';
import 'package:kilocal_flutter_app/features/path/data/vimeo_oembed_service.dart';
import 'package:mocktail/mocktail.dart';

class _MockGraphqlClient extends Mock implements GraphqlClient {}

class _MockDio extends Mock implements Dio {}

class _MockVimeoOembedService extends Mock implements VimeoOembedService {}

const _posterUrl = 'https://i.vimeocdn.com/video/123_960x540.jpg';

/// One row of the normalized REST payload.
Map<String, dynamic> _material({
  required String id,
  String title = 'Materiale',
  String contentSource = 'material',
  Map<String, dynamic>? image,
  String? thumbnailUrl,
  bool completed = false,
  String internalName = 'ricette',
}) => {
  'id': id,
  'status': 'published',
  'content_source': contentSource,
  'translations': [
    {'languages_code': 'it-IT', 'title': title, 'excerpt': null},
  ],
  'image': image,
  'thumbnail_url': thumbnailUrl,
  'categories': [
    {'id': 'cat-1', 'internal_name': internalName, 'title': 'Categoria'},
  ],
  'tags': <dynamic>[],
  'completed': completed,
};

void main() {
  late _MockDio dio;
  late _MockGraphqlClient client;
  late _MockVimeoOembedService oembed;
  late PathMaterialsRepositoryImpl repository;

  setUp(() {
    dio = _MockDio();
    client = _MockGraphqlClient();
    oembed = _MockVimeoOembedService();
    when(() => oembed.fetchAll(any())).thenAnswer((_) async => {});
    repository = PathMaterialsRepositoryImpl(
      graphqlClient: client,
      dio: dio,
      vimeoOembedService: oembed,
    );
  });

  /// Stubs the materials endpoint with [materials].
  void stubEndpoint(List<Map<String, dynamic>> materials) {
    when(() => dio.get<Map<String, dynamic>>(any())).thenAnswer(
      (invocation) async => Response(
        requestOptions: RequestOptions(
          path: invocation.positionalArguments.first as String,
        ),
        statusCode: 200,
        data: {
          'data': {
            'area': 'alimentazione',
            'group_id': '17',
            'category_id': null,
            'materials': materials,
          },
        },
      ),
    );
  }

  test('reads the area/group materials endpoint', () async {
    stubEndpoint([_material(id: '1')]);

    await repository.fetchMaterials(groupId: '17', area: 'alimentazione');

    verify(
      () => dio.get<Map<String, dynamic>>(
        '/path/me/areas/alimentazione/groups/17/materials',
      ),
    ).called(1);
  });

  test('a recipe shows the title the server took from its article', () async {
    // The broken recipes: the material itself carries no title/cover, so the
    // server falls back to the linked article. Reading the material alone (the
    // old GraphQL list) is what rendered these as empty cards.
    stubEndpoint([
      _material(
        id: '1',
        title: 'Vellutata di zucca',
        contentSource: 'article',
        image: {
          'asset_is_video': false,
          'default_asset': {
            'id': 'article-cover',
            'filename_download': 'cover.jpg',
          },
        },
      ),
    ]);

    final data = await repository.fetchMaterials(
      groupId: '17',
      area: 'alimentazione',
    );

    final material = data.materials.single;
    expect(material.title, 'Vellutata di zucca');
    expect(material.imageUrl, contains('article-cover'));
  });

  test('a video with no cover file falls back to thumbnail_url', () async {
    stubEndpoint([
      _material(
        id: '1',
        image: {'asset_is_video': true, 'vimeo_url': 'https://vimeo.com/1'},
        thumbnailUrl: _posterUrl,
      ),
    ]);

    final data = await repository.fetchMaterials(
      groupId: '17',
      area: 'alimentazione',
    );

    expect(data.materials.single.imageUrl, _posterUrl);
    expect(data.materials.single.isVideo, isTrue);
  });

  test('a cover file wins over thumbnail_url', () async {
    stubEndpoint([
      _material(
        id: '1',
        image: {
          'asset_is_video': true,
          'default_asset': {'id': 'own-file', 'filename_download': 'own.jpg'},
        },
        thumbnailUrl: _posterUrl,
      ),
    ]);

    final data = await repository.fetchMaterials(
      groupId: '17',
      area: 'alimentazione',
    );

    expect(data.materials.single.imageUrl, contains('own-file'));
  });

  test('completion comes from the server, not user_activities', () async {
    stubEndpoint([_material(id: '1', completed: true), _material(id: '2')]);

    final data = await repository.fetchMaterials(
      groupId: '17',
      area: 'alimentazione',
    );

    expect(data.materials.map((m) => m.isCompleted), [true, false]);
    // The old path issued a second GraphQL read to intersect completions.
    verifyNever(() => client.query(any(), variables: any(named: 'variables')));
  });

  test('category tabs are de-duplicated in first-seen order', () async {
    stubEndpoint([
      _material(id: '1', internalName: 'ricette'),
      _material(id: '2', internalName: 'ricette'),
    ]);

    final data = await repository.fetchMaterials(
      groupId: '17',
      area: 'alimentazione',
    );

    expect(data.categories.single.id, 'cat-1');
    expect(data.categories.single.title, 'Categoria');
  });

  test('"Schede" cards are listed without a cover', () async {
    stubEndpoint([_material(id: '1', internalName: 'schede')]);

    final data = await repository.fetchMaterials(
      groupId: '17',
      area: 'alimentazione',
    );

    expect(data.materials.single.hidesImage, isTrue);
  });

  group('against the real staging payload', () {
    // Captured from the live endpoint on staging (2026-08-11), five rows that
    // between them cover every shape the mapper has to handle: a text material
    // with no image and one with a cover (allenamento/17), a Vimeo video whose
    // `default_asset` is null but which carries a server-resolved
    // `thumbnail_url`, an article-sourced recipe, and a cover-less "scheda"
    // (alimentazione/30).
    setUp(() {
      final json = File(
        'test/features/path/data/fixtures/area_materials_response.json',
      ).readAsStringSync();
      when(() => dio.get<Map<String, dynamic>>(any())).thenAnswer(
        (invocation) async => Response(
          requestOptions: RequestOptions(
            path: invocation.positionalArguments.first as String,
          ),
          statusCode: 200,
          data: {'data': jsonDecode(json)},
        ),
      );
    });

    test('maps every row without dropping any', () async {
      final data = await repository.fetchMaterials(
        groupId: '17',
        area: 'allenamento',
      );

      expect(data.materials, hasLength(5));
      expect(
        data.materials.every((m) => m.title.isNotEmpty),
        isTrue,
        reason: 'a blank title is the empty-card bug this migration fixes',
      );
    });

    test('an article-sourced recipe carries title and cover', () async {
      final data = await repository.fetchMaterials(
        groupId: '17',
        area: 'allenamento',
      );

      // Recipe id 83: `content_source: article`, so both the title and the
      // cover were resolved server-side from the linked published article.
      // Read from the material alone this row used to render as an empty card.
      final recipe = data.materials.firstWhere((m) => m.id == '83');
      expect(recipe.title, 'Mousse di Avocado e Limone');
      expect(recipe.imageUrl, contains('/assets/'));
      expect(recipe.isVideo, isFalse);
    });

    test('a "scheda" keeps no cover and is not badged as video', () async {
      final data = await repository.fetchMaterials(
        groupId: '17',
        area: 'allenamento',
      );

      final scheda = data.materials.firstWhere((m) => m.id == '3');
      expect(scheda.imageUrl, isNull);
      expect(scheda.isVideo, isFalse);
      expect(scheda.hidesImage, isTrue);
    });

    test('the Vimeo video gets its server-resolved poster', () async {
      final data = await repository.fetchMaterials(
        groupId: '17',
        area: 'allenamento',
      );

      final video = data.materials.firstWhere((m) => m.isVideo);
      expect(video.imageUrl, startsWith('https://i.vimeocdn.com/'));
    });

    test('files with no filename_download still build a valid url', () async {
      final data = await repository.fetchMaterials(
        groupId: '17',
        area: 'allenamento',
      );

      // The REST payload omits `filename_download`; the url must not end in a
      // dangling slash.
      final withCover = data.materials.firstWhere(
        (m) => !m.isVideo && m.imageUrl != null,
      );
      expect(withCover.imageUrl, contains('/assets/'));
      expect(withCover.imageUrl, isNot(endsWith('/')));
      expect(Uri.tryParse(withCover.imageUrl!), isNotNull);
    });

    test('category tabs come through localized', () async {
      final data = await repository.fetchMaterials(
        groupId: '17',
        area: 'allenamento',
      );

      expect(
        data.categories.map((c) => c.title),
        containsAll(<String>['Consigli utili', 'Video']),
      );
    });
  });

  test('falls back to GraphQL when the area is unknown', () async {
    when(
      () => client.query(any(), variables: any(named: 'variables')),
    ).thenAnswer((invocation) async {
      final query = invocation.positionalArguments.first as String;
      if (query.contains('user_activities')) {
        return {
          'data': {'user_activities': <dynamic>[]},
        };
      }
      return {
        'data': {'percorsi_groups_percorsi_materials': <dynamic>[]},
      };
    });

    await repository.fetchMaterials(groupId: '17');

    verifyNever(() => dio.get<Map<String, dynamic>>(any()));
    verify(
      () => client.query(any(), variables: any(named: 'variables')),
    ).called(greaterThan(0));
  });
}
