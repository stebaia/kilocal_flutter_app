import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kilocal_flutter_app/core/network/graphql_client.dart';
import 'package:kilocal_flutter_app/features/integrazione/domain/entities/integrazione_data.dart';
import 'package:kilocal_flutter_app/features/integrazione/domain/integrazione_repository.dart';
import 'package:kilocal_flutter_app/features/statistics/data/statistics_repository_impl.dart';
import 'package:kilocal_flutter_app/features/statistics/domain/entities/area_stat.dart';
import 'package:kilocal_flutter_app/l10n/app_localizations_it.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

class _MockGraphqlClient extends Mock implements GraphqlClient {}

class _MockIntegrazioneRepository extends Mock
    implements IntegrazioneRepository {}

/// A phase with a single supplement, so `total` == [durationDays] and
/// `completed` == [takenDays].
IntegrazionePhase _phase({
  required String id,
  required int sort,
  int durationDays = 30,
  int takenDays = 0,
}) => IntegrazionePhase(
  id: id,
  title: 'Fase $sort',
  sort: sort,
  products: [
    IntegrazioneProduct(
      id: 'p$id',
      title: 'Prodotto $id',
      durationDays: durationDays,
      quantity: 1,
      tracking: IntegrazioneTracking(
        id: 't$id',
        tookDates: List.generate(
          takenDays,
          (i) => DateTime(2026, 1, 1).add(Duration(days: i)),
        ),
      ),
    ),
  ],
);

Map<String, dynamic> _progressResponse({
  required Map<String, List<int>> areas, // area -> [completed, total]
}) {
  Map<String, dynamic> count(int completed, int total) => {
    'completed': completed,
    'total': total,
    'percent': total == 0 ? 0 : (completed * 100 ~/ total),
  };
  return {
    'data': {
      'overall': count(3, 30),
      'areas': {
        for (final entry in areas.entries)
          entry.key: count(entry.value[0], entry.value[1]),
      },
    },
  };
}

/// One `used_in` entry linking a content to its area; [mainTab] mirrors
/// `percorsi_groups.is_percorso_main_tab`.
Map<String, dynamic> _usedIn(String area, {bool mainTab = true}) => {
  'percorsi_groups_id': {
    'is_percorso_main_tab': mainTab,
    'percorso': {
      'root': {'internal_name': area},
    },
  },
};

void main() {
  late _MockDio dio;
  late _MockGraphqlClient graphql;
  late _MockIntegrazioneRepository integrazione;
  late StatisticsRepositoryImpl repository;
  final l10n = AppLocalizationsIt();

  setUp(() {
    dio = _MockDio();
    graphql = _MockGraphqlClient();
    integrazione = _MockIntegrazioneRepository();
    repository = StatisticsRepositoryImpl(
      dio: dio,
      graphqlClient: graphql,
      integrazioneRepository: integrazione,
    );
  });

  /// Stubs the user's supplement plan (phases + current phase).
  void stubIntegrazione({
    required List<IntegrazionePhase> phases,
    String? currentPhaseId,
  }) {
    when(
      () => integrazione.fetchIntegrazione(
        myId: any(named: 'myId'),
        lang: any(named: 'lang'),
      ),
    ).thenAnswer(
      (_) async => IntegrazioneData(
        phases: phases,
        currentPhaseId: currentPhaseId,
        kitId: '5',
      ),
    );
  }

  void stubProgress(Map<String, dynamic> body) {
    when(
      () => dio.get<Map<String, dynamic>>(
        '/path/me/progress',
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => Response(
        data: body,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/path/me/progress'),
      ),
    );
  }

  group('fetchStatistics (lifetime)', () {
    test('maps the per-area counts from /path/me/progress', () async {
      stubProgress(
        _progressResponse(
          areas: {
            'allenamento': [2, 10],
            'alimentazione': [1, 8],
            'integrazione': [4, 12],
          },
        ),
      );

      final stats = await repository.fetchStatistics(l10n);

      expect(stats, hasLength(3));
      expect(stats[0].id, 'allenamento');
      expect(stats[0].completed, 2);
      expect(stats[0].total, 10);
      expect(stats[1].id, 'alimentazione');
      expect(stats[1].completed, 1);
      expect(stats[2].id, 'integrazione');
      expect(stats[2].completed, 4);
    });

    test(
      'adds a cache-busting query param to defeat the URL-keyed cache',
      () async {
        stubProgress(
          _progressResponse(
            areas: {
              'allenamento': [0, 0],
              'alimentazione': [0, 0],
              'integrazione': [0, 0],
            },
          ),
        );

        await repository.fetchStatistics(l10n);

        final captured = verify(
          () => dio.get<Map<String, dynamic>>(
            '/path/me/progress',
            queryParameters: captureAny(named: 'queryParameters'),
          ),
        ).captured;
        expect(captured.single, isA<Map<String, dynamic>>());
        expect((captured.single as Map<String, dynamic>).keys, contains('_'));
      },
    );
  });

  group('fetchStatistics (month filter)', () {
    const timeframe = AreaTimeframe(id: 7, title: 'Mese 2', sort: 2);

    void stubGraphql({
      required List<Map<String, dynamic>> activities,
      required List<Map<String, dynamic>> contents,
    }) {
      when(
        () => graphql.query(any(that: contains('StatisticsMonthCompleted'))),
      ).thenAnswer(
        (_) async => {
          'data': {'user_activities': activities},
        },
      );
      when(
        () => graphql.query(any(that: contains('StatisticsMonthTotals'))),
      ).thenAnswer(
        (_) async => {
          'data': {'percorsi_content': contents},
        },
      );
    }

    test(
      'counts completed/total per step area from GraphQL on timeframe.sort',
      () async {
        stubProgress(
          _progressResponse(
            areas: {
              'allenamento': [9, 99],
              'alimentazione': [9, 99],
              'integrazione': [4, 12],
            },
          ),
        );
        stubGraphql(
          activities: [
            // Completed in the selected month, training.
            {
              'activity': [
                {
                  'item': {
                    'id': 'c1',
                    'timeframe': {'sort': 2},
                    'used_in': [_usedIn('allenamento')],
                  },
                },
              ],
            },
            // Completed in another month — ignored.
            {
              'activity': [
                {
                  'item': {
                    'id': 'c2',
                    'timeframe': {'sort': 1},
                    'used_in': [_usedIn('allenamento')],
                  },
                },
              ],
            },
            // Completed in the selected month, nutrition.
            {
              'activity': [
                {
                  'item': {
                    'id': 'c3',
                    'timeframe': {'sort': 2},
                    'used_in': [_usedIn('alimentazione')],
                  },
                },
              ],
            },
          ],
          contents: [
            {
              'id': 'c1',
              'used_in': [_usedIn('allenamento')],
            },
            {
              'id': 'c2',
              'used_in': [_usedIn('allenamento')],
            },
            {
              'id': 'c3',
              'used_in': [_usedIn('alimentazione')],
            },
            // Materials-only content (no main-tab group) — not counted.
            {
              'id': 'c4',
              'used_in': [_usedIn('allenamento', mainTab: false)],
            },
          ],
        );

        // Phase 2 reached, 10 of its 30 days taken.
        stubIntegrazione(
          phases: [
            _phase(id: '1', sort: 1, durationDays: 30, takenDays: 30),
            _phase(id: '2', sort: 2, durationDays: 30, takenDays: 10),
          ],
          currentPhaseId: '2',
        );

        final stats = await repository.fetchStatistics(
          l10n,
          timeframe: timeframe,
          myId: 'user-1',
        );

        expect(stats[0].id, 'allenamento');
        expect(stats[0].completed, 1);
        expect(stats[0].total, 2);
        expect(stats[1].id, 'alimentazione');
        expect(stats[1].completed, 1);
        expect(stats[1].total, 1);
        // Phase-based area reports the phase matching the selected month,
        // not the lifetime 4/12.
        expect(stats[2].id, 'integrazione');
        expect(stats[2].completed, 10);
        expect(stats[2].total, 30);
      },
    );

    test(
      'reports 0 for integrazione when the month is not unlocked yet',
      () async {
        stubProgress(
          _progressResponse(
            areas: {
              'allenamento': [0, 0],
              'alimentazione': [0, 0],
              // Lifetime shows real progress from the phases already done…
              'integrazione': [30, 90],
            },
          ),
        );
        stubGraphql(activities: const [], contents: const []);
        // …but the user is still on phase 1, so month 2 is locked.
        stubIntegrazione(
          phases: [
            _phase(id: '1', sort: 1, durationDays: 30, takenDays: 30),
            _phase(id: '2', sort: 2, durationDays: 30, takenDays: 0),
            _phase(id: '3', sort: 3, durationDays: 30, takenDays: 0),
          ],
          currentPhaseId: '1',
        );

        final stats = await repository.fetchStatistics(
          l10n,
          timeframe: timeframe,
          myId: 'user-1',
        );

        final integrazioneStat = stats.firstWhere(
          (s) => s.id == 'integrazione',
        );
        expect(integrazioneStat.completed, 0);
        expect(integrazioneStat.total, 0);
        expect(integrazioneStat.percent, 0);
      },
    );

    test('falls back to lifetime for integrazione without a user id', () async {
      stubProgress(
        _progressResponse(
          areas: {
            'allenamento': [0, 0],
            'alimentazione': [0, 0],
            'integrazione': [4, 12],
          },
        ),
      );
      stubGraphql(activities: const [], contents: const []);

      final stats = await repository.fetchStatistics(
        l10n,
        timeframe: timeframe,
      );

      final integrazioneStat = stats.firstWhere((s) => s.id == 'integrazione');
      expect(integrazioneStat.completed, 4);
      expect(integrazioneStat.total, 12);
      verifyNever(
        () => integrazione.fetchIntegrazione(
          myId: any(named: 'myId'),
          lang: any(named: 'lang'),
        ),
      );
    });

    test(
      'reports 0 when the kit has no phase for the selected month',
      () async {
        stubProgress(
          _progressResponse(
            areas: {
              'allenamento': [0, 0],
              'alimentazione': [0, 0],
              'integrazione': [4, 12],
            },
          ),
        );
        stubGraphql(activities: const [], contents: const []);
        // Kit with a single phase, but month 2 is selected.
        stubIntegrazione(
          phases: [_phase(id: '1', sort: 1)],
          currentPhaseId: '1',
        );

        final stats = await repository.fetchStatistics(
          l10n,
          timeframe: timeframe,
          myId: 'user-1',
        );

        final integrazioneStat = stats.firstWhere(
          (s) => s.id == 'integrazione',
        );
        expect(integrazioneStat.completed, 0);
        expect(integrazioneStat.total, 0);
      },
    );

    test('inlines the timeframe sort into the totals query filter', () async {
      stubProgress(
        _progressResponse(
          areas: {
            'allenamento': [0, 0],
            'alimentazione': [0, 0],
            'integrazione': [0, 0],
          },
        ),
      );
      stubGraphql(activities: const [], contents: const []);
      stubIntegrazione(phases: const [], currentPhaseId: null);

      await repository.fetchStatistics(l10n, timeframe: timeframe);

      // Directus rejects an Int! variable here (`_eq` on `timeframe.sort` is
      // typed GraphQLStringOrFloat), so the month is interpolated directly.
      final captured = verify(
        () =>
            graphql.query(captureAny(that: contains('StatisticsMonthTotals'))),
      ).captured;
      expect(captured.single as String, contains('_eq: 2'));
    });
  });
}
