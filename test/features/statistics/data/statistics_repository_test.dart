import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kilocal_flutter_app/core/network/graphql_client.dart';
import 'package:kilocal_flutter_app/features/statistics/data/statistics_repository_impl.dart';
import 'package:kilocal_flutter_app/features/statistics/domain/entities/area_stat.dart';
import 'package:kilocal_flutter_app/l10n/app_localizations_it.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

class _MockGraphqlClient extends Mock implements GraphqlClient {}

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
  late StatisticsRepositoryImpl repository;
  final l10n = AppLocalizationsIt();

  setUp(() {
    dio = _MockDio();
    graphql = _MockGraphqlClient();
    repository = StatisticsRepositoryImpl(dio: dio, graphqlClient: graphql);
  });

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

        final stats = await repository.fetchStatistics(
          l10n,
          timeframe: timeframe,
        );

        expect(stats[0].id, 'allenamento');
        expect(stats[0].completed, 1);
        expect(stats[0].total, 2);
        expect(stats[1].id, 'alimentazione');
        expect(stats[1].completed, 1);
        expect(stats[1].total, 1);
        // Phase-based area keeps its lifetime value under the month filter.
        expect(stats[2].id, 'integrazione');
        expect(stats[2].completed, 4);
        expect(stats[2].total, 12);
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
