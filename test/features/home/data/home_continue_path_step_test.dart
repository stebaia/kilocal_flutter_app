import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kilocal_flutter_app/core/network/graphql_client.dart';
import 'package:kilocal_flutter_app/features/home/data/home_repository_impl.dart';
import 'package:kilocal_flutter_app/features/path/data/vimeo_oembed_service.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

class _MockGraphqlClient extends Mock implements GraphqlClient {}

class _MockVimeoOembedService extends Mock implements VimeoOembedService {}

/// The home "Continua il percorso" card must resolve its destination *step*
/// the same way the Percorso tab does when the user opens that area's
/// current month (`PathAreaDetailScreen._openTimeframe`): the current
/// timeframe group's first not-yet-completed step. Previously it trusted the
/// CMS `curr_step` snapshot directly, which could point at a different step
/// than the one the area screen itself would open — see
/// [[home-continue-path-image-gap]] and the "continua il percorso"
/// discrepancy bug.
void main() {
  late _MockDio dio;
  late _MockGraphqlClient graphql;
  late _MockVimeoOembedService vimeo;
  late HomeRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(
      RequestOptions(path: '/path/me/areas/allenamento/steps'),
    );
  });

  setUp(() {
    dio = _MockDio();
    graphql = _MockGraphqlClient();
    vimeo = _MockVimeoOembedService();
    repository = HomeRepositoryImpl(
      graphqlClient: graphql,
      dio: dio,
      vimeoOembedService: vimeo,
    );
  });

  void stubContinueAndTextQuery({required Set<String> areasWithCurrStep}) {
    when(
      () => graphql.query(
        any(that: contains('HomeContinueAndText')),
        variables: any(named: 'variables'),
      ),
    ).thenAnswer(
      (_) async => {
        'data': {
          'user_details': [
            {
              'percorso_allenamento_curr_step':
                  areasWithCurrStep.contains('allenamento')
                  ? {'id': 'whatever'}
                  : null,
              'percorso_alimentazione_curr_step':
                  areasWithCurrStep.contains('alimentazione')
                  ? {'id': 'whatever'}
                  : null,
              'percorso_benessere_curr_step':
                  areasWithCurrStep.contains('benessere')
                  ? {'id': 'whatever'}
                  : null,
            },
          ],
          'private_pages': <dynamic>[],
        },
      },
    );
  }

  void stubOtherQueries() {
    when(
      () => graphql.query(
        any(that: contains('HomeMonthProgress')),
        variables: any(named: 'variables'),
      ),
    ).thenAnswer(
      (_) async => {
        'data': {'total': <dynamic>[], 'activities': <dynamic>[]},
      },
    );
    when(
      () => graphql.query(
        any(that: contains('HomeMoments')),
        variables: any(named: 'variables'),
      ),
    ).thenAnswer(
      (_) async => {
        'data': {'moments': <dynamic>[]},
      },
    );
    when(
      () => dio.get<Map<String, dynamic>>(
        '/path/me/progress',
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => Response(
        data: const {
          'data': {
            'overall': {'completed': 1, 'total': 10},
            'areas': <String, dynamic>{},
          },
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/path/me/progress'),
      ),
    );
  }

  Map<String, dynamic> stepJson({
    required String id,
    required bool completed,
    required int timeframeId,
    bool timeframeIsCurrent = false,
    bool timeframeLocked = false,
  }) => {
    'id': id,
    'sort': 0,
    'completed': completed,
    'started': completed,
    'is_current': false,
    'locked': false,
    'timeframe': {
      'id': timeframeId,
      'sort': timeframeId,
      'translations': <dynamic>[],
      'is_current': timeframeIsCurrent,
      'locked': timeframeLocked,
    },
    'translations': [
      {'languages_code': 'it-IT', 'title': 'Step $id'},
    ],
    'asset': {
      'asset_is_video': false,
      'default_asset': 'asset-$id',
      'translations': <dynamic>[],
    },
  };

  void stubAreaSteps(String area, List<Map<String, dynamic>> steps) {
    when(
      () => dio.get<Map<String, dynamic>>('/path/me/areas/$area/steps'),
    ).thenAnswer(
      (_) async => Response(
        data: {
          'data': {
            'area': area,
            'percorso': {
              'id': '1',
              'internal_name': area,
              'has_progressive_steps': true,
            },
            'progress': {'completed': 0, 'total': steps.length, 'percent': 0},
            'groups': [
              {
                'id': 'g1',
                'is_percorso_main_tab': true,
                'translations': <dynamic>[],
                'steps': steps,
              },
            ],
          },
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/path/me/areas/$area/steps'),
      ),
    );
  }

  test('picks the first not-yet-completed step of the current timeframe group, '
      'like the Percorso tab does', () async {
    stubContinueAndTextQuery(areasWithCurrStep: {'allenamento'});
    stubOtherQueries();
    stubAreaSteps('allenamento', [
      // Month 1: fully completed — not the current one.
      stepJson(id: 'm1-s1', completed: true, timeframeId: 1),
      // Month 2: current, with a completed step then the real target.
      stepJson(
        id: 'm2-s1',
        completed: true,
        timeframeId: 2,
        timeframeIsCurrent: true,
      ),
      stepJson(
        id: 'm2-s2',
        completed: false,
        timeframeId: 2,
        timeframeIsCurrent: true,
      ),
    ]);

    final data = await repository.fetchHome(
      myId: 'u1',
      currentMonth: 2,
      userName: 'Test',
    );

    expect(data.continuePath.area, 'allenamento');
    expect(data.continuePath.stepId, 'm2-s2');
  });

  test('falls back to the group\'s first step when the current month is fully '
      'completed', () async {
    stubContinueAndTextQuery(areasWithCurrStep: {'allenamento'});
    stubOtherQueries();
    stubAreaSteps('allenamento', [
      stepJson(
        id: 'm1-s1',
        completed: true,
        timeframeId: 1,
        timeframeIsCurrent: true,
      ),
      stepJson(
        id: 'm1-s2',
        completed: true,
        timeframeId: 1,
        timeframeIsCurrent: true,
      ),
    ]);

    final data = await repository.fetchHome(
      myId: 'u1',
      currentMonth: 1,
      userName: 'Test',
    );

    expect(data.continuePath.stepId, 'm1-s1');
  });

  test('still picks the area in fixed order (allenamento first) regardless of '
      'which one the user last engaged with', () async {
    stubContinueAndTextQuery(
      areasWithCurrStep: {'allenamento', 'alimentazione'},
    );
    stubOtherQueries();
    stubAreaSteps('allenamento', [
      stepJson(
        id: 'a-s1',
        completed: false,
        timeframeId: 1,
        timeframeIsCurrent: true,
      ),
    ]);

    final data = await repository.fetchHome(
      myId: 'u1',
      currentMonth: 1,
      userName: 'Test',
    );

    expect(data.continuePath.area, 'allenamento');
    verifyNever(
      () => dio.get<Map<String, dynamic>>('/path/me/areas/alimentazione/steps'),
    );
  });

  test(
    'falls back to the generic start card when the area has no steps',
    () async {
      stubContinueAndTextQuery(areasWithCurrStep: {'allenamento'});
      stubOtherQueries();
      stubAreaSteps('allenamento', []);

      final data = await repository.fetchHome(
        myId: 'u1',
        currentMonth: 1,
        userName: 'Test',
      );

      expect(data.continuePath.stepId, isNull);
      expect(data.continuePath.area, isNull);
    },
  );
}
