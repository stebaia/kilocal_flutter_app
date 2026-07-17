import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kilocal_flutter_app/core/network/graphql_client.dart';
import 'package:kilocal_flutter_app/features/path/data/path_materials_repository_impl.dart';
import 'package:kilocal_flutter_app/features/path/data/vimeo_oembed_service.dart';
import 'package:mocktail/mocktail.dart';

class _MockGraphqlClient extends Mock implements GraphqlClient {}

class _MockDio extends Mock implements Dio {}

class _MockVimeoOembedService extends Mock implements VimeoOembedService {}

const _vimeoUrl = 'https://vimeo.com/123456';
const _posterUrl = 'https://i.vimeocdn.com/video/123_960x540.jpg';

/// One junction row wrapping a material with the given asset/categories.
Map<String, dynamic> _material({
  required String id,
  Map<String, dynamic>? asset,
  String? categoryHeroId,
  String categoryInternalName = 'cat',
}) => {
  'percorsi_materials_id': {
    'id': id,
    'status': 'published',
    'asset': asset,
    'translations': [
      {'title': 'Materiale $id'},
    ],
    'categories': [
      if (categoryHeroId != null)
        {
          'percorsi_material_categories_id': {
            'id': 'cat-1',
            'internal_name': categoryInternalName,
            'hero_asset': {
              'default_asset': {
                'id': categoryHeroId,
                'filename_download': 'hero.jpg',
              },
            },
            'translations': [
              {'title': 'Categoria'},
            ],
          },
        },
    ],
  },
};

void main() {
  late _MockGraphqlClient client;
  late _MockVimeoOembedService oembed;
  late PathMaterialsRepositoryImpl repository;

  setUp(() {
    client = _MockGraphqlClient();
    oembed = _MockVimeoOembedService();
    repository = PathMaterialsRepositoryImpl(
      graphqlClient: client,
      dio: _MockDio(),
      vimeoOembedService: oembed,
    );
  });

  /// Stubs the junction query with [rows] and an empty completed-activities list.
  void stubMaterials(List<Map<String, dynamic>> rows) {
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
        'data': {'percorsi_groups_percorsi_materials': rows},
      };
    });
  }

  test('a video material uses its Vimeo poster as the cover', () async {
    stubMaterials([
      _material(
        id: '1',
        asset: {'asset_is_video': true, 'vimeo_url': _vimeoUrl},
        categoryHeroId: 'hero-file',
      ),
    ]);
    when(() => oembed.fetchAll(any())).thenAnswer(
      (_) async => {_vimeoUrl: const VimeoOembed(thumbnailUrl: _posterUrl)},
    );

    final data = await repository.fetchMaterials(groupId: 'g1');

    expect(data.materials.single.imageUrl, _posterUrl);
  });

  test(
    'a video material falls back to the category hero when oEmbed fails',
    () async {
      stubMaterials([
        _material(
          id: '1',
          asset: {'asset_is_video': true, 'vimeo_url': _vimeoUrl},
          categoryHeroId: 'hero-file',
        ),
      ]);
      when(() => oembed.fetchAll(any())).thenAnswer((_) async => {});

      final data = await repository.fetchMaterials(groupId: 'g1');

      expect(data.materials.single.imageUrl, contains('hero-file'));
    },
  );

  test('a material with its own asset keeps that cover', () async {
    stubMaterials([
      _material(
        id: '1',
        asset: {
          'asset_is_video': false,
          'default_asset': {'id': 'own-file', 'filename_download': 'own.jpg'},
        },
        categoryHeroId: 'hero-file',
      ),
    ]);
    when(() => oembed.fetchAll(any())).thenAnswer((_) async => {});

    final data = await repository.fetchMaterials(groupId: 'g1');

    expect(data.materials.single.imageUrl, contains('own-file'));
  });

  test('a "Consigli utili" material is flagged image-less', () async {
    stubMaterials([
      _material(
        id: '1',
        asset: {
          'asset_is_video': false,
          'default_asset': {'id': 'own-file', 'filename_download': 'own.jpg'},
        },
        categoryHeroId: 'hero-file',
        categoryInternalName: 'consigli-utili',
      ),
    ]);
    when(() => oembed.fetchAll(any())).thenAnswer((_) async => {});

    final data = await repository.fetchMaterials(groupId: 'g1');

    expect(data.materials.single.hidesImage, isTrue);
    expect(data.categories.single.isAdvice, isTrue);
  });

  test('a material outside "Consigli utili" keeps its image', () async {
    stubMaterials([_material(id: '1', categoryHeroId: 'hero-file')]);
    when(() => oembed.fetchAll(any())).thenAnswer((_) async => {});

    final data = await repository.fetchMaterials(groupId: 'g1');

    expect(data.materials.single.hidesImage, isFalse);
  });

  test('a "Consigli utili" detail is flagged image-less', () async {
    when(
      () => client.query(any(), variables: any(named: 'variables')),
    ).thenAnswer(
      (_) async => {
        'data': {
          'percorsi_materials_by_id': {
            'id': '1',
            'translations': [
              {'title': 'Consiglio', 'content': '<p>Corpo</p>'},
            ],
            'categories': [
              {
                'percorsi_material_categories_id': {
                  'id': 'cat-1',
                  'internal_name': 'consigli-utili',
                },
              },
            ],
          },
        },
      },
    );

    final detail = await repository.fetchMaterialDetail(id: '1');

    expect(detail!.hidesImage, isTrue);
  });
}
