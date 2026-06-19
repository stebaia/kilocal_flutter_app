import 'package:kilocal_flutter_app/l10n/app_localizations.dart';

import '../../features/home/domain/entities/home_data.dart';
import '../../features/momenti/domain/entities/momenti_data.dart';
import '../../features/statistics/domain/entities/area_stat.dart';

/// Centralized factory for localized mock data.
///
/// Every user-facing string is resolved via [AppLocalizations] so the mock
/// data respects the current locale. Replace this factory with real
/// repositories once the backend contracts are defined.
abstract final class MockDataFactory {
  MockDataFactory._();

  static HomeData homeData(AppLocalizations l10n) {
    return HomeData(
      userName: 'Mariagiovanna',
      currentDate: DateTime(2026, 9, 3),
      continuePath: ContinuePathItem(
        title: l10n.homePathCardTitle,
        subtitle: l10n.homeContinuePath,
        imageUrl: 'https://placehold.co/400x320/e51e4d/ffffff?text=Path',
      ),
      monthStats: MonthStats(
        monthLabel: l10n.month1,
        description: l10n.homeMonthStatsDescription,
        progress: 0.80,
      ),
      actionCards: [
        HomeActionCard(
          title: l10n.homeMoments,
          imageUrl: 'https://placehold.co/200x200/ffffff/e51e4d?text=Momenti',
          route: '/momenti/home',
          assetName: 'assets/postcard.png',
        ),
        HomeActionCard(
          title: l10n.homeBenefits,
          imageUrl: 'https://placehold.co/200x200/ffffff/e51e4d?text=Benefit',
          route: '/benefits',
          assetName: 'assets/letter.png',
        ),
      ],
    );
  }

  static List<AreaStat> statistics(AppLocalizations l10n) {
    return [
      AreaStat(
        area: l10n.areaTraining,
        month: l10n.month1,
        completed: 3,
        total: 15,
      ),
      AreaStat(
        area: l10n.areaNutrition,
        month: l10n.month1,
        completed: 5,
        total: 18,
      ),
      AreaStat(
        area: l10n.areaWellbeing,
        month: l10n.month1,
        completed: 8,
        total: 25,
      ),
      AreaStat(
        area: l10n.areaIntegration,
        month: l10n.phase1,
        completed: 5,
        total: 19,
      ),
    ];
  }

  static MomentiData momenti(AppLocalizations l10n) {
    return MomentiData(
      title: l10n.homeHeroTitle,
      body: l10n.homeProgress,
      heroImageUrl: 'https://placehold.co/600x300/e51e4d/ffffff?text=Momenti',
      meccanica: [
        MeccanicaItem(
          day: '${l10n.month1} 1',
          description: l10n.diaryCompleted,
        ),
        MeccanicaItem(day: '${l10n.month1} 2', description: l10n.diaryPending),
        MeccanicaItem(day: '${l10n.month1} 3', description: l10n.areaTraining),
        MeccanicaItem(day: '${l10n.month1} 4', description: l10n.areaNutrition),
        MeccanicaItem(day: '${l10n.month1} 5', description: l10n.areaWellbeing),
        MeccanicaItem(
          day: '${l10n.month1} 6',
          description: l10n.areaIntegration,
        ),
        MeccanicaItem(
          day: '${l10n.month1} 7',
          description: l10n.statisticsTitle,
        ),
      ],
    );
  }
}
