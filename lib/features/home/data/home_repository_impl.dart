import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/graphql_client.dart';
import '../../../core/utils/cms_image_url.dart';
import '../../path/data/dto/path_area_steps_dto.dart';
import '../../path/data/dto/path_progress_dto.dart';
import '../../path/data/vimeo_oembed_service.dart';
import '../domain/entities/home_data.dart';
import '../domain/home_repository.dart';
import 'dto/home_continue_step_dto.dart';
import 'dto/home_month_progress_dto.dart';
import 'dto/home_moment_dto.dart';

/// Repository implementation that loads the home dashboard from GraphQL,
/// plus the lifetime path progress from `GET /path/me/progress` (REST) used
/// to decide the "Inizia"/"Continua il percorso" CTA.
class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl({
    required GraphqlClient graphqlClient,
    required Dio dio,
    required VimeoOembedService vimeoOembedService,
  }) : _graphqlClient = graphqlClient,
       _dio = dio,
       _vimeoOembedService = vimeoOembedService;

  final GraphqlClient _graphqlClient;
  final Dio _dio;
  final VimeoOembedService _vimeoOembedService;

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
    }
    percorso_alimentazione_curr_step {
      id
    }
    percorso_benessere_curr_step {
      id
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
    final hasStarted = await _fetchHasStartedPath();

    final (continueStepDto, monthText) = continueAndText;
    final continueStep =
        continueStepDto ??
        const HomeContinueStepDto(
          title: _continueFallbackTitle,
          ctaLabel: _defaultCtaLabel,
        );

    final continueImage = await _resolveContinueImage(continueStep);

    final momentImage = _momentFallbackImage;

    return HomeData(
      userName: userName,
      currentDate: DateTime.now(),
      continuePath: ContinuePathItem(
        title: continueStep.title ?? _continueFallbackTitle,
        subtitle: continueStep.ctaLabel,
        imageUrl: continueImage,
        hasStarted: hasStarted,
        stepId: continueStep.stepId,
        area: continueStep.area,
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
          assetName: _momentFallbackImage,
          isLocked: true,
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

      // Pick the first area (in fixed order) that has a CMS current step —
      // this only decides *which area* to continue.
      final area = _firstAreaWithCurrStep(details);
      // The actual step to deep-link into is then resolved the same way the
      // Percorso tab does it (see `PathAreaDetailScreen._openTimeframe`):
      // the current month's first not-yet-completed step, falling back to
      // its first step — rather than trusting the CMS `curr_step` snapshot,
      // which can point at a different step than what the area screen itself
      // would open.
      final step = area == null ? null : await _fetchContinueStep(area, lang);

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
        vimeoUrl: step?['vimeo_url'] as String?,
        stepId: step?['step_id'] as String?,
        area: step?['area'] as String?,
      );

      return (dto, monthText);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// The first area (in fixed order) whose CMS `curr_step` is set — this only
  /// decides which of the three areas the home card continues; the step
  /// itself is then resolved by [_fetchContinueStep].
  String? _firstAreaWithCurrStep(Map<String, dynamic>? details) {
    if (details == null) return null;
    const stepKeys = {
      'percorso_allenamento_curr_step': 'allenamento',
      'percorso_alimentazione_curr_step': 'alimentazione',
      'percorso_benessere_curr_step': 'benessere',
    };
    for (final entry in stepKeys.entries) {
      if (details[entry.key] != null) return entry.value;
    }
    return null;
  }

  /// Resolves the step to deep-link into for [area], mirroring exactly what
  /// `PathAreaDetailScreen._openTimeframe` opens when the user taps that
  /// area's current month from the Percorso tab: the current timeframe group
  /// (`isCurrent`, falling back to the last unlocked, not-yet-completed one),
  /// then its first not-yet-completed step (or its first step, if the month
  /// is already done). Returns `null` on any read failure — the caller then
  /// falls back to the generic "Inizia il tuo percorso" card.
  Future<Map<String, dynamic>?> _fetchContinueStep(
    String area,
    String lang,
  ) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/path/me/areas/$area/steps',
      );
      final dto = PathAreaStepsResponseDto.fromJson(response.data ?? const {});

      PathGroupDto? mainGroup;
      for (final g in dto.data.groups) {
        if (g.isPercorsoMainTab) {
          mainGroup = g;
          break;
        }
      }
      final steps = mainGroup?.steps ?? const <PathStepDto>[];
      if (steps.isEmpty) return null;

      final stepsByTimeframe = <int, List<PathStepDto>>{};
      for (final step in steps) {
        stepsByTimeframe.putIfAbsent(step.timeframe.id, () => []).add(step);
      }

      List<PathStepDto>? currentGroup;
      for (final group in stepsByTimeframe.values) {
        if (group.first.timeframe.isCurrent ?? false) {
          currentGroup = group;
          break;
        }
      }
      if (currentGroup == null) {
        for (final group in stepsByTimeframe.values.toList().reversed) {
          final locked = group.first.timeframe.locked ?? false;
          final completed = group.where((s) => s.completed).length;
          if (!locked && completed < group.length) {
            currentGroup = group;
            break;
          }
        }
      }
      currentGroup ??= steps;

      final step = currentGroup.firstWhere(
        (s) => !s.completed,
        orElse: () => currentGroup!.first,
      );

      final title = step.translations.titleFor(lang);
      final asset = step.asset;
      return <String, dynamic>{
        'title': title,
        'image_file_id': asset.assetIsVideo ? null : asset.defaultAsset,
        'image_file_name': null,
        'vimeo_url': asset.assetIsVideo ? asset.vimeoUrl : null,
        'step_id': step.id,
        'area': area,
      };
    } on ApiException {
      return null;
    } on DioException {
      return null;
    }
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

  /// Resolves the "continua il percorso" hero image: the CMS
  /// `default_asset`/`mobile_asset` when present, otherwise the Vimeo oEmbed
  /// poster for the step's video (156/157 `percorsi_content` rows have no CMS
  /// cover image — confirmed by backend, 2026-07). Falls back to the static
  /// asset only when neither is available. See
  /// [[home-continue-path-image-gap]].
  Future<String> _resolveContinueImage(HomeContinueStepDto step) async {
    final imageFileId = step.imageFileId;
    if (imageFileId != null) {
      // The filename suffix is optional — Directus serves an asset by id
      // alone (see `PathRepositoryImpl._mapStepDto`), which matters here
      // since the REST `/path/me/areas/{area}/steps` step data (unlike the
      // GraphQL `curr_step` this used to read) carries only the file id.
      return cmsImageUrl(
        imageFileId,
        size: CmsImageSize.card,
        filename: step.imageFileName,
      )!;
    }
    final vimeoUrl = step.vimeoUrl;
    if (vimeoUrl != null) {
      final oembed = await _vimeoOembedService.fetch(vimeoUrl);
      if (oembed?.thumbnailUrl != null) return oembed!.thumbnailUrl!;
    }
    return _continueFallbackImage;
  }

  /// Whether the user has completed at least one step in any path area,
  /// used to pick "Inizia il percorso" vs "Continua il percorso". Defaults to
  /// `false` (start state) if the progress endpoint is unreachable.
  Future<bool> _fetchHasStartedPath() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/path/me/progress',
        // The server caches this endpoint keyed by exact URL; a monotonic
        // throwaway param forces a fresh read after step completions.
        queryParameters: {'_': DateTime.now().millisecondsSinceEpoch},
      );
      final dto = PathProgressResponseDto.fromJson(response.data ?? const {});
      return dto.data.overall.completed > 0;
    } on ApiException {
      return false;
    } on DioException {
      return false;
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
