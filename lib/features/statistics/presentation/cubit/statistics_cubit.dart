import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../user/presentation/cubit/user_cubit.dart';
import '../../domain/entities/area_stat.dart';
import '../../domain/statistics_repository.dart';

part 'statistics_state.dart';

class StatisticsCubit extends Cubit<StatisticsState> {
  StatisticsCubit({
    required StatisticsRepository statisticsRepository,
    UserCubit? userCubit,
    List<AreaStat>? initialData,
  }) : _statisticsRepository = statisticsRepository,
       _userCubit = userCubit,
       super(StatisticsState(stats: initialData ?? const []));

  final StatisticsRepository _statisticsRepository;

  /// Session user, needed to resolve the phase-based `integrazione` stats
  /// under a month filter (the kit/phases are per-user).
  final UserCubit? _userCubit;

  /// Area whose timeframes drive both the default selection and the filter
  /// sheet (see [[statistics-feature-status]] — every area's timeframes are
  /// independent, so a single one is used as the common list).
  static const referenceArea = 'allenamento';

  /// Whether the initial default (current month) has been resolved already.
  /// Resolved once per cubit lifetime, so a later explicit selection/clear is
  /// never overridden by a reload.
  var _defaultTimeframeResolved = false;

  /// Seeds the cubit with ready-made data (used by tests).
  void loadWithData(List<AreaStat> data) {
    emit(StatisticsState(status: StatisticsStatus.loaded, stats: data));
  }

  Future<void> load(AppLocalizations l10n) async {
    emit(state.copyWith(status: StatisticsStatus.loading));
    try {
      if (!_defaultTimeframeResolved) {
        _defaultTimeframeResolved = true;
        await _resolveDefaultTimeframe(l10n);
      }
      final stats = await _statisticsRepository.fetchStatistics(
        l10n,
        timeframe: state.selectedTimeframe,
        myId: _userCubit?.state.user?.id,
      );
      emit(state.copyWith(status: StatisticsStatus.loaded, stats: stats));
    } catch (_) {
      emit(state.copyWith(status: StatisticsStatus.error));
    }
  }

  /// Defaults the filter to the current month (design: "Statistiche mese
  /// corrente"). Best-effort: if the timeframes cannot be loaded, the screen
  /// falls back to lifetime progress.
  Future<void> _resolveDefaultTimeframe(AppLocalizations l10n) async {
    try {
      final timeframes = await _statisticsRepository.fetchAreaTimeframes(
        area: referenceArea,
        l10n: l10n,
      );
      if (timeframes.isEmpty) return;
      final current = timeframes.firstWhere(
        (tf) => tf.isCurrent,
        orElse: () => timeframes.first,
      );
      emit(state.copyWith(selectedTimeframe: current));
    } catch (_) {
      // Keep lifetime as the fallback view.
    }
  }

  /// Fetches the reference area's selectable timeframes for the filter sheet.
  Future<List<AreaTimeframe>> fetchTimeframes(
    AppLocalizations l10n, {
    required String referenceArea,
  }) {
    return _statisticsRepository.fetchAreaTimeframes(
      area: referenceArea,
      l10n: l10n,
    );
  }

  /// Applies (or clears, when [timeframe] is null) the timeframe filter and
  /// reloads every area's stats.
  Future<void> selectTimeframe(
    AppLocalizations l10n,
    AreaTimeframe? timeframe,
  ) {
    // An explicit choice (including clearing) suppresses the initial
    // current-month default, so the next [load] cannot override it.
    _defaultTimeframeResolved = true;
    emit(
      state.copyWith(
        selectedTimeframe: timeframe,
        clearSelectedTimeframe: timeframe == null,
      ),
    );
    return load(l10n);
  }
}
