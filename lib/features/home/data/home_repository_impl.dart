import 'package:dio/dio.dart';

import '../../../core/config/env.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/graphql_client.dart';
import '../domain/entities/home_data.dart';
import '../domain/home_repository.dart';
import 'dto/home_continue_step_dto.dart';
import 'dto/home_month_progress_dto.dart';
import 'dto/home_moment_dto.dart';

/// Repository implementation that loads the home dashboard from GraphQL.
class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl({required GraphqlClient graphqlClient})
    : _graphqlClient = graphqlClient;

  final GraphqlClient _graphqlClient;

  static const _defaultCtaLabel = 'Continua';
  static const _defaultMonthText = 'Le tue attività completate nel mese';
  static const _continueFallbackTitle = 'Inizia il tuo percorso';
  static const _continueFallbackImage = 'assets/training.png';
  static const _momentFallbackImage = 'assets/postcard.png';
  static const _benefitFallbackImage = 'assets/letter.png';

  static const _continueAndTextQuery = r'''
query HomeContinueAndText($myId: ID!, $lang: String!) {
  user_details(filter: { user: { id: { _eq: $myId } } }) {
    percorso_allenamento_curr_step {
      id
      sort
      translations(filter: { languages_code: { code: { _eq: $lang } } }) {
        title
      }
      asset {
        default_asset {
          id
          filename_download
        }
      }
    }
    percorso_alimentazione_curr_step {
      id
      sort
      translations(filter: { languages_code: { code: { _eq: $lang } } }) {
        title
      }
      asset {
        default_asset {
          id
          filename_download
        }
      }
    }
    percorso_benessere_curr_step {
      id
      sort
      translations(filter: { languages_code: { code: { _eq: $lang } } }) {
        title
      }
      asset {
        default_asset {
          id
          filename_download
        }
      }
    }
  }
  private_pages(filter: { internal_name: { _eq: "dashboard" } }) {
    sections {
      collection
      item {
        ... on private_sec_hero {
          translations(filter: { languages_code: { code: { _eq: $lang } } }) {
            cta_continue_label
          }
        }
        ... on private_sec_charts {
          translations(filter: { languages_code: { code: { _eq: $lang } } }) {
            month_text
          }
        }
      }
    }
  }
}
''';

  static const _monthProgressQueryTemplate = r'''
query HomeMonthProgress($myId: ID!) {
  total: percorsi_content_aggregated(
    groupBy: ["timeframe"]
    filter: { timeframe: { sort: { _eq: {{month}} } } }
  ) {
    count { id }
    group
  }
  activities: user_activities(
    filter: {
      user: { id: { _eq: $myId } }
      completed_on: { _nnull: true }
    }
  ) {
    activity {
      item {
        ... on percorsi_content {
          id
          timeframe { sort }
        }
      }
    }
  }
}
''';

  static const _momentsQuery = r'''
query HomeMoments($now: String!, $lang: String!) {
  moments(
    filter: {
      starts_on: { _lte: $now }
      ends_on: { _gte: $now }
    }
    limit: 1
  ) {
    id
    translations(filter: { languages_code: { code: { _eq: $lang } } }) {
      title
    }
    asset {
      default_asset {
        id
        filename_download
      }
    }
  }
}
''';

  @override
  Future<HomeData> fetchHome({
    required String myId,
    required int currentMonth,
    required String userName,
  }) async {
    final lang = _resolveLocale();
    final now = DateTime.now().toUtc().toIso8601String();

    final continueAndText = await _fetchContinueAndText(myId, lang);
    final monthProgress = await _fetchMonthProgress(myId, currentMonth);
    final moment = await _fetchMoment(now, lang);

    final (continueStepDto, monthText) = continueAndText;
    final continueStep =
        continueStepDto ??
        const HomeContinueStepDto(
          title: _continueFallbackTitle,
          ctaLabel: _defaultCtaLabel,
        );

    final continueImage = continueStep.imageFileId != null
        ? '${Env.baseUrl}/assets/${continueStep.imageFileId}/${continueStep.imageFileName}'
        : _continueFallbackImage;

    final momentImage = moment?.imageFileId != null
        ? '${Env.baseUrl}/assets/${moment!.imageFileId}/${moment.imageFileName}'
        : _momentFallbackImage;

    return HomeData(
      userName: userName,
      currentDate: DateTime.now(),
      continuePath: ContinuePathItem(
        title: continueStep.title ?? _continueFallbackTitle,
        subtitle: continueStep.ctaLabel,
        imageUrl: continueImage,
      ),
      monthStats: MonthStats(
        monthLabel: 'Mese $currentMonth',
        description: _monthDescription(
          monthText: monthText,
          completed: monthProgress?.completed ?? 0,
        ),
        progress: computeProgress(
          monthProgress?.completed ?? 0,
          monthProgress?.total ?? 0,
        ),
      ),
      actionCards: [
        HomeActionCard(
          title: 'Momenti',
          imageUrl: momentImage,
          route: '/momenti/home',
          assetName: moment?.imageFileId == null ? _momentFallbackImage : null,
        ),
        HomeActionCard(
          title: 'Benefit',
          imageUrl: _benefitFallbackImage,
          route: '/benefits',
          assetName: _benefitFallbackImage,
        ),
      ],
    );
  }

  Future<(HomeContinueStepDto?, String?)> _fetchContinueAndText(
    String myId,
    String lang,
  ) async {
    try {
      final result = await _graphqlClient.query(
        _continueAndTextQuery,
        variables: {'myId': myId, 'lang': lang},
      );

      final data = result['data'] as Map<String, dynamic>?;
      if (data == null) return (null, null);

      final detailsList = data['user_details'] as List<dynamic>?;
      final details = detailsList?.firstOrNull as Map<String, dynamic>?;

      // Pick the first non-null current step among the three areas.
      final step = _firstNonNullStep(details, lang);

      final pages = data['private_pages'] as List<dynamic>?;
      final dashboard = pages?.firstOrNull as Map<String, dynamic>?;
      final sections = dashboard?['sections'] as List<dynamic>?;

      String? ctaLabel;
      String? monthText;
      for (final section in sections ?? <dynamic>[]) {
        final s = section as Map<String, dynamic>;
        final collection = s['collection'] as String?;
        final item = s['item'] as Map<String, dynamic>?;
        final translations = item?['translations'] as List<dynamic>?;
        final trans = translations?.firstOrNull as Map<String, dynamic>?;
        if (collection == 'private_sec_hero') {
          ctaLabel = trans?['cta_continue_label'] as String?;
        } else if (collection == 'private_sec_charts') {
          monthText = trans?['month_text'] as String?;
        }
      }

      final dto = HomeContinueStepDto(
        title: step?['title'] as String?,
        imageFileId: step?['image_file_id'] as String?,
        imageFileName: step?['image_file_name'] as String?,
        ctaLabel: ctaLabel,
      );

      return (dto, monthText);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Map<String, dynamic>? _firstNonNullStep(
    Map<String, dynamic>? details,
    String lang,
  ) {
    if (details == null) return null;
    const stepKeys = [
      'percorso_allenamento_curr_step',
      'percorso_alimentazione_curr_step',
      'percorso_benessere_curr_step',
    ];
    for (final key in stepKeys) {
      final step = details[key] as Map<String, dynamic>?;
      if (step == null) continue;
      final title = _translation(step, lang)?['title'] as String?;
      final asset = step['asset'] as Map<String, dynamic>?;
      final file = asset?['default_asset'] as Map<String, dynamic>?;
      return <String, dynamic>{
        'title': title,
        'image_file_id': file?['id'],
        'image_file_name': file?['filename_download'],
      };
    }
    return null;
  }

  Map<String, dynamic>? _translation(Map<String, dynamic> node, String lang) {
    final translations = node['translations'] as List<dynamic>?;
    if (translations == null || translations.isEmpty) return null;
    return translations.firstOrNull as Map<String, dynamic>?;
  }

  Future<HomeMonthProgressDto?> _fetchMonthProgress(
    String myId,
    int month,
  ) async {
    try {
      final query = _monthProgressQueryTemplate.replaceAll(
        '{{month}}',
        month.toString(),
      );
      final result = await _graphqlClient.query(
        query,
        variables: {'myId': myId},
      );

      final data = result['data'] as Map<String, dynamic>?;
      if (data == null) return null;

      final totalAgg = data['total'] as List<dynamic>?;
      final totalGroup = totalAgg?.firstOrNull as Map<String, dynamic>?;
      final total =
          (totalGroup?['count'] as Map<String, dynamic>?)?['id'] as int?;

      final activities = data['activities'] as List<dynamic>?;
      var completed = 0;
      for (final activity in activities ?? <dynamic>[]) {
        final act = activity as Map<String, dynamic>;
        final items = act['activity'] as List<dynamic>?;
        for (final itemWrapper in items ?? <dynamic>[]) {
          final wrapper = itemWrapper as Map<String, dynamic>;
          final item = wrapper['item'] as Map<String, dynamic>?;
          if (item == null) continue;
          final timeframe = item['timeframe'] as Map<String, dynamic>?;
          final sort = timeframe?['sort'] as int?;
          if (sort == month) {
            completed++;
            break;
          }
        }
      }

      return HomeMonthProgressDto(total: total, completed: completed);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<HomeMomentDto?> _fetchMoment(String now, String lang) async {
    try {
      final result = await _graphqlClient.query(
        _momentsQuery,
        variables: {'now': now, 'lang': lang},
      );

      final data = result['data'] as Map<String, dynamic>?;
      final moments = data?['moments'] as List<dynamic>?;
      final moment = moments?.firstOrNull as Map<String, dynamic>?;
      if (moment == null) return null;

      final title = _translation(moment, lang)?['title'] as String?;
      final asset = moment['asset'] as Map<String, dynamic>?;
      final file = asset?['default_asset'] as Map<String, dynamic>?;

      return HomeMomentDto(
        id: moment['id'] as String?,
        title: title,
        imageFileId: file?['id'] as String?,
        imageFileName: file?['filename_download'] as String?,
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Replaces the CMS placeholder `{{num}}` with the actual completed count.
  String _monthDescription({String? monthText, required int completed}) {
    final text = monthText ?? _defaultMonthText;
    return text.replaceAll('{{num}}', completed.toString());
  }

  /// Computes month progress as `completed / total`, guarding against `total == 0`.
  static double computeProgress(int completed, int total) {
    if (total == 0) return 0.0;
    return completed / total;
  }

  String _resolveLocale() {
    // The CMS uses codes like "it-IT" / "en-US". Default to Italian for now.
    return 'it-IT';
  }
}
