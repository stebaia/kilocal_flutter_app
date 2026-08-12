import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kilocal_flutter_app/features/statistics/data/statistics_repository_impl.dart';
import 'package:kilocal_flutter_app/features/statistics/domain/entities/area_stat.dart';
import 'package:kilocal_flutter_app/l10n/app_localizations_it.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

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

void main() {
  late _MockDio dio;
  late StatisticsRepositoryImpl repository;
  final l10n = AppLocalizationsIt();

  setUp(() {
    dio = _MockDio();
    repository = StatisticsRepositoryImpl(dio: dio);
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

  /// The `queryParameters` of the single `/path/me/progress` call.
  Map<String, dynamic> capturedQuery() {
    final captured = verify(
      () => dio.get<Map<String, dynamic>>(
        '/path/me/progress',
        queryParameters: captureAny(named: 'queryParameters'),
      ),
    ).captured;
    return captured.single as Map<String, dynamic>;
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

    test('omits benessere even when the backend returns it', () async {
      stubProgress(
        _progressResponse(
          areas: {
            'allenamento': [2, 10],
            'alimentazione': [1, 8],
            'benessere': [13, 54],
            'integrazione': [4, 12],
          },
        ),
      );

      final stats = await repository.fetchStatistics(l10n);

      expect(stats.map((s) => s.id), isNot(contains('benessere')));
    });

    test('sends no timeframe_id when no month is selected', () async {
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

      expect(capturedQuery(), isNot(contains('timeframe_id')));
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

        expect(capturedQuery().keys, contains('_'));
      },
    );
  });

  group('fetchStatistics (month filter)', () {
    const timeframe = AreaTimeframe(id: 7, title: 'Mese 2', sort: 2);

    test('passes the timeframe id through as timeframe_id', () async {
      stubProgress(
        _progressResponse(
          areas: {
            'allenamento': [0, 0],
            'alimentazione': [0, 0],
            'integrazione': [0, 0],
          },
        ),
      );

      await repository.fetchStatistics(l10n, timeframe: timeframe);

      // The id, not the sort — the backend keys the filter on `timeframe_id`.
      expect(capturedQuery()['timeframe_id'], 7);
    });

    test('maps the month-scoped counts the backend returns', () async {
      stubProgress(
        _progressResponse(
          areas: {
            'allenamento': [2, 8],
            'alimentazione': [4, 4],
            'integrazione': [5, 20],
          },
        ),
      );

      final stats = await repository.fetchStatistics(
        l10n,
        timeframe: timeframe,
      );

      expect(stats[0].completed, 2);
      expect(stats[0].total, 8);
      expect(stats[1].completed, 4);
      expect(stats[1].total, 4);
      // `integrazione` is reported in content steps like every other area,
      // straight from the endpoint — no client-side phase math.
      expect(stats[2].id, 'integrazione');
      expect(stats[2].completed, 5);
      expect(stats[2].total, 20);
    });

    test('reports 0/0 for an area the month has no content for', () async {
      stubProgress(
        _progressResponse(
          areas: {
            'allenamento': [2, 8],
            'alimentazione': [4, 4],
            'integrazione': [0, 0],
          },
        ),
      );

      final stats = await repository.fetchStatistics(
        l10n,
        timeframe: timeframe,
      );

      final integrazioneStat = stats.firstWhere((s) => s.id == 'integrazione');
      expect(integrazioneStat.completed, 0);
      expect(integrazioneStat.total, 0);
      expect(integrazioneStat.percent, 0);
    });

    test('defaults a missing area to 0/0 instead of throwing', () async {
      stubProgress(
        _progressResponse(
          areas: {
            'allenamento': [2, 8],
          },
        ),
      );

      final stats = await repository.fetchStatistics(
        l10n,
        timeframe: timeframe,
      );

      expect(stats, hasLength(3));
      expect(stats[1].completed, 0);
      expect(stats[1].total, 0);
    });
  });
}
