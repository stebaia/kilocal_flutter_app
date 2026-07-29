import 'package:flutter_test/flutter_test.dart';
import 'package:kilocal_flutter_app/core/network/api_exception.dart';
import 'package:kilocal_flutter_app/features/statistics/domain/entities/area_stat.dart';
import 'package:kilocal_flutter_app/features/statistics/domain/statistics_repository.dart';
import 'package:kilocal_flutter_app/features/statistics/presentation/cubit/statistics_cubit.dart';
import 'package:kilocal_flutter_app/l10n/app_localizations_it.dart';
import 'package:mocktail/mocktail.dart';

class _MockStatisticsRepository extends Mock implements StatisticsRepository {}

void main() {
  late _MockStatisticsRepository repository;
  late StatisticsCubit cubit;
  final l10n = AppLocalizationsIt();

  const month1 = AreaTimeframe(id: 1, title: 'Mese 1', sort: 1);
  const month2 = AreaTimeframe(
    id: 2,
    title: 'Mese 2',
    sort: 2,
    isCurrent: true,
  );

  setUpAll(() {
    registerFallbackValue(AppLocalizationsIt());
  });

  setUp(() {
    repository = _MockStatisticsRepository();
    cubit = StatisticsCubit(statisticsRepository: repository);
    when(
      () =>
          repository.fetchStatistics(any(), timeframe: any(named: 'timeframe')),
    ).thenAnswer((_) async => const <AreaStat>[]);
  });

  void stubTimeframes(List<AreaTimeframe> timeframes) {
    when(
      () => repository.fetchAreaTimeframes(
        area: any(named: 'area'),
        l10n: any(named: 'l10n'),
      ),
    ).thenAnswer((_) async => timeframes);
  }

  test('load defaults the filter to the current month', () async {
    stubTimeframes([month1, month2]);

    await cubit.load(l10n);

    expect(cubit.state.status, StatisticsStatus.loaded);
    expect(cubit.state.selectedTimeframe, month2);
    final captured = verify(
      () => repository.fetchStatistics(
        any(),
        timeframe: captureAny(named: 'timeframe'),
      ),
    ).captured;
    expect(captured.single, month2);
  });

  test('load falls back to the first timeframe when none is current', () async {
    stubTimeframes([month1, month2.copyWithNoCurrent]);

    await cubit.load(l10n);

    expect(cubit.state.selectedTimeframe, month1);
  });

  test(
    'load falls back to lifetime when timeframes cannot be loaded',
    () async {
      when(
        () => repository.fetchAreaTimeframes(
          area: any(named: 'area'),
          l10n: any(named: 'l10n'),
        ),
      ).thenThrow(
        const ApiException(
          type: ApiErrorType.unknown,
          statusCode: 500,
          message: 'boom',
        ),
      );

      await cubit.load(l10n);

      expect(cubit.state.status, StatisticsStatus.loaded);
      expect(cubit.state.selectedTimeframe, isNull);
      final captured = verify(
        () => repository.fetchStatistics(
          any(),
          timeframe: captureAny(named: 'timeframe'),
        ),
      ).captured;
      expect(captured.single, isNull);
    },
  );

  test('an explicit selection is kept on subsequent loads', () async {
    stubTimeframes([month1, month2]);

    await cubit.selectTimeframe(l10n, month1);
    await cubit.load(l10n);

    expect(cubit.state.selectedTimeframe, month1);
    final captured = verify(
      () => repository.fetchStatistics(
        any(),
        timeframe: captureAny(named: 'timeframe'),
      ),
    ).captured;
    // One fetch from selectTimeframe + one from load, both with month1.
    expect(captured, [month1, month1]);
  });
}

extension on AreaTimeframe {
  /// [month2] without the current flag, for the no-current-fallback case.
  AreaTimeframe get copyWithNoCurrent =>
      AreaTimeframe(id: id, title: title, sort: sort);
}
