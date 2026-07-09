import 'package:flutter_test/flutter_test.dart';
import 'package:kilocal_flutter_app/core/network/graphql_client.dart';
import 'package:kilocal_flutter_app/features/path/data/path_materials_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

class _MockGraphqlClient extends Mock implements GraphqlClient {}

/// GraphQL response for the group→materials junction query, one row per id.
Map<String, dynamic> _junction(List<String> materialIds) => {
  'data': {
    'percorsi_groups_percorsi_materials': [
      for (final id in materialIds)
        {
          'percorsi_materials_id': {'id': id},
        },
    ],
  },
};

/// GraphQL response for the completed-activities query. Each entry is the
/// material id a completed activity links to; a `null` entry simulates an
/// activity on a different collection (must be ignored).
Map<String, dynamic> _completed(List<String?> materialIds) => {
  'data': {
    'user_activities': [
      for (final id in materialIds)
        {
          'activity': [
            {
              'collection': id == null ? 'percorsi_content' : 'percorsi_materials',
              'item': id == null
                  ? {'__typename': 'percorsi_content', 'id': '999'}
                  : {'__typename': 'percorsi_materials', 'id': id},
            },
          ],
        },
    ],
  },
};

void main() {
  late _MockGraphqlClient client;
  late PathMaterialsRepositoryImpl repository;

  setUp(() {
    client = _MockGraphqlClient();
    repository = PathMaterialsRepositoryImpl(graphqlClient: client);
  });

  /// Stubs the client so the completed-materials query and each group's
  /// junction query resolve to their respective payloads. The queries are told
  /// apart by a substring of the GraphQL document.
  void stub({
    required List<String?> completed,
    required Map<String, List<String>> groupMaterials,
  }) {
    when(
      () => client.query(any(), variables: any(named: 'variables')),
    ).thenAnswer((invocation) async {
      final doc = invocation.positionalArguments.first as String;
      final variables =
          invocation.namedArguments[#variables] as Map<String, dynamic>?;

      if (doc.contains('user_activities')) {
        return _completed(completed);
      }
      final groupId = variables?['groupId'].toString();
      return _junction(groupMaterials[groupId] ?? const []);
    });
  }

  test('total is the group material count; completed is the intersection',
      () async {
    stub(
      completed: ['m1', 'm3', 'm9'],
      groupMaterials: {
        'g1': ['m1', 'm2', 'm3'], // 2 of 3 completed
        'g2': ['m4', 'm5'], // 0 completed
      },
    );

    final progress = await repository.fetchGroupProgress(
      groupIds: ['g1', 'g2'],
    );

    expect(progress['g1']!.completed, 2);
    expect(progress['g1']!.total, 3);
    expect(progress['g2']!.completed, 0);
    expect(progress['g2']!.total, 2);
  });

  test('ignores completed activities on other collections', () async {
    // The completed feed carries a percorsi_content activity (null) alongside a
    // material one; only the material must count.
    stub(
      completed: [null, 'm1'],
      groupMaterials: {
        'g1': ['m1', 'm2'],
      },
    );

    final progress = await repository.fetchGroupProgress(groupIds: ['g1']);

    expect(progress['g1']!.completed, 1);
    expect(progress['g1']!.total, 2);
  });

  test('a group with no materials is 0/0', () async {
    stub(
      completed: ['m1'],
      groupMaterials: {'g1': <String>[]},
    );

    final progress = await repository.fetchGroupProgress(groupIds: ['g1']);

    expect(progress['g1']!.completed, 0);
    expect(progress['g1']!.total, 0);
  });

  test('empty groupIds short-circuits without querying', () async {
    final progress = await repository.fetchGroupProgress(groupIds: []);

    expect(progress, isEmpty);
    verifyNever(() => client.query(any(), variables: any(named: 'variables')));
  });
}
