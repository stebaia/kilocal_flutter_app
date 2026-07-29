import 'package:dio/dio.dart';

import '../../../core/config/env.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/graphql_client.dart';
import '../domain/entities/integrazione_data.dart';
import '../domain/integrazione_repository.dart';
import 'dto/integrazione_dto.dart';

/// GraphQL-backed implementation of [IntegrazioneRepository].
///
/// Resolves the user's kit and current phase from `user_details`, then loads
/// the kit's phases and supplements from `kit_products`. See [[integrazione]].
class IntegrazioneRepositoryImpl implements IntegrazioneRepository {
  IntegrazioneRepositoryImpl({required GraphqlClient graphqlClient})
    : _graphqlClient = graphqlClient;

  final GraphqlClient _graphqlClient;

  /// Resolves the user's kit id + current phase id in one call.
  static const _userContextQuery = r'''
query IntegrazioneContext($myId: ID!) {
  user_details(filter: { user: { id: { _eq: $myId } } }) {
    id
    percorso_integrazione_curr_phase { id }
    profile { kit { id } }
  }
}
''';

  /// Loads the phases + supplements for a given kit.
  static const _kitProductsQuery = r'''
query KitProducts($kitId: GraphQLStringOrFloat!, $lang: String!) {
  kit_products(
    filter: { kit: { id: { _eq: $kitId } } }
    sort: ["sort"]
  ) {
    id
    sort
    only_for_gender
    phase {
      id
      sort
      translations { languages_code { code } title }
    }
    products_with_duration {
      kit_products_duration_id {
        id
        duration
        quantity
        product {
          id
          title
          use_for_barcode_check
          asset { id default_asset { id filename_download } }
          translations(filter: { languages_code: { code: { _eq: $lang } } }) {
            languages_code { code }
            instructions
            timing
            description
            avvertenze
          }
        }
      }
    }
  }
}
''';

  /// Loads the user's intake tracking rows for a kit.
  static const _trackingQuery = r'''
query UserIntegratori($kitId: GraphQLStringOrFloat!) {
  user_integratori(filter: { kit: { id: { _eq: $kitId } } }) {
    id
    product { id }
    took_dates
    started_on
    ended_on
    expected_to_end_on
    delay_days
  }
}
''';

  // kit/product are typed `Int` (FK ids), took_dates is `JSON`, started_on
  // `Date` — verified via schema introspection. `user` is inferred by Directus
  // from the auth token.
  static const _createTrackingMutation = r'''
mutation CreateTracking(
  $kitId: Int!
  $productId: Int!
  $tookDates: JSON!
  $started: Date!
) {
  create_user_integratori_item(
    data: {
      kit: $kitId
      product: $productId
      took_dates: $tookDates
      started_on: $started
    }
  ) {
    id
    took_dates
    started_on
  }
}
''';

  static const _updateTrackingMutation = r'''
mutation UpdateTracking($id: ID!, $tookDates: JSON!) {
  update_user_integratori_item(id: $id, data: { took_dates: $tookDates }) {
    id
  }
}
''';

  // `percorso_integrazione_curr_phase` is a M2O whose input field is typed `Int`
  // (the FK id), verified via schema introspection — not `ID`.
  static const _setPhaseMutation = r'''
mutation SetCurrentPhase($id: ID!, $phaseId: Int!) {
  update_user_details_item(
    id: $id
    data: { percorso_integrazione_curr_phase: $phaseId }
  ) {
    id
  }
}
''';

  @override
  Future<IntegrazioneData> fetchIntegrazione({
    required String myId,
    required String lang,
  }) async {
    try {
      final contextResult = await _graphqlClient.query(
        _userContextQuery,
        variables: {'myId': myId},
      );
      final details =
          (contextResult['data'] as Map<String, dynamic>?)?['user_details']
              as List<dynamic>?;
      final detail = details?.firstOrNull as Map<String, dynamic>?;
      if (detail == null) {
        return const IntegrazioneData(phases: []);
      }

      final currentPhaseId =
          ((detail['percorso_integrazione_curr_phase']
                  as Map<String, dynamic>?)?['id'])
              ?.toString();
      final kitId =
          (((detail['profile'] as Map<String, dynamic>?)?['kit']
                  as Map<String, dynamic>?)?['id'])
              ?.toString();

      if (kitId == null) {
        return IntegrazioneData(
          phases: const [],
          currentPhaseId: currentPhaseId,
        );
      }

      final kitResult = await _graphqlClient.query(
        _kitProductsQuery,
        variables: {'kitId': kitId, 'lang': lang},
      );
      final rawRows =
          (kitResult['data'] as Map<String, dynamic>?)?['kit_products']
              as List<dynamic>?;

      // Load the user's intake tracking and index it by product id so each
      // product can be enriched with its own record.
      final trackingResult = await _graphqlClient.query(
        _trackingQuery,
        variables: {'kitId': kitId},
      );
      final rawTracking =
          (trackingResult['data'] as Map<String, dynamic>?)?['user_integratori']
              as List<dynamic>?;
      final trackingByProduct = <String, IntegrazioneTracking>{};
      for (final json in rawTracking ?? const []) {
        final dto = UserIntegratoreDto.fromJson(json as Map<String, dynamic>);
        final productId = dto.product?.id;
        if (productId != null) {
          trackingByProduct[productId] = _mapTracking(dto);
        }
      }

      final phases =
          rawRows
              ?.map(
                (json) => KitProductDto.fromJson(json as Map<String, dynamic>),
              )
              .map((dto) => _mapPhase(dto, lang, trackingByProduct))
              .whereType<IntegrazionePhase>()
              .toList() ??
          <IntegrazionePhase>[];

      phases.sort((a, b) => a.sort.compareTo(b.sort));

      return IntegrazioneData(
        phases: phases,
        currentPhaseId: currentPhaseId,
        kitId: kitId,
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  @override
  Future<void> setCurrentPhase({
    required String userDetailsId,
    required String phaseId,
  }) async {
    try {
      await _graphqlClient.query(
        _setPhaseMutation,
        variables: {
          'id': userDetailsId,
          // The mutation input is typed Int; ids elsewhere are strings.
          'phaseId': int.parse(phaseId),
        },
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  IntegrazionePhase? _mapPhase(
    KitProductDto dto,
    String lang,
    Map<String, IntegrazioneTracking> trackingByProduct,
  ) {
    final phase = dto.phase;
    if (phase == null) return null;

    final title = _titleFor(phase.translations, lang) ?? '';
    final products = dto.productsWithDuration
        .map((junction) => junction.durationEntry)
        .whereType<ProductDurationDto>()
        .map((entry) => _mapProduct(entry, trackingByProduct))
        .whereType<IntegrazioneProduct>()
        .toList();

    return IntegrazionePhase(
      id: phase.id,
      title: title,
      // Prefer the phase's own sort; fall back to the kit_products row sort.
      sort: phase.sort ?? dto.sort ?? 0,
      products: products,
    );
  }

  IntegrazioneProduct? _mapProduct(
    ProductDurationDto dto,
    Map<String, IntegrazioneTracking> trackingByProduct,
  ) {
    final product = dto.product;
    if (product == null) return null;

    // `products.asset` is an `assets` entity, not a file; the actual image file
    // lives in `asset.default_asset`. Building `/assets/<asset.id>` yields a
    // broken image (placeholder icon) — the CDN needs the file id.
    final file = product.asset?.defaultAsset;
    final imageUrl = file?.id != null
        ? '${Env.baseUrl}/assets/${file!.id}/${file.filenameDownload ?? ''}'
        : null;
    final translation = product.translations.firstOrNull;

    return IntegrazioneProduct(
      id: product.id,
      title: product.title ?? '',
      durationDays: dto.duration ?? 0,
      quantity: dto.quantity ?? 1,
      imageUrl: imageUrl,
      useForBarcodeCheck: product.useForBarcodeCheck,
      instructions: translation?.instructions,
      timing: translation?.timing,
      description: translation?.description,
      avvertenze: translation?.avvertenze,
      tracking: trackingByProduct[product.id],
    );
  }

  IntegrazioneTracking _mapTracking(UserIntegratoreDto dto) {
    return IntegrazioneTracking(
      id: dto.id,
      tookDates: dto.tookDates,
      startedOn: dto.startedOn,
      endedOn: dto.endedOn,
      expectedToEndOn: dto.expectedToEndOn,
      delayDays: dto.delayDays,
    );
  }

  @override
  Future<void> markTaken({
    required String myId,
    required String productId,
    required String kitId,
    String? trackingId,
    required DateTime day,
  }) async {
    try {
      final dayIso = _dateOnly(day);

      if (trackingId == null) {
        // First intake for this product: create the record with today's date.
        await _graphqlClient.query(
          _createTrackingMutation,
          variables: {
            'kitId': int.parse(kitId),
            'productId': int.parse(productId),
            'tookDates': [dayIso],
            'started': dayIso,
          },
        );
        return;
      }

      // Existing record: re-read, append today (idempotently), and write back.
      final existing = await _currentTookDates(
        trackingId: trackingId,
        kitId: kitId,
      );
      if (!existing.contains(dayIso)) existing.add(dayIso);

      await _graphqlClient.query(
        _updateTrackingMutation,
        variables: {'id': trackingId, 'tookDates': existing},
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  @override
  Future<void> unmarkTaken({
    required String trackingId,
    required String kitId,
    required DateTime day,
  }) async {
    try {
      final dayIso = _dateOnly(day);
      final existing = await _currentTookDates(
        trackingId: trackingId,
        kitId: kitId,
      );
      existing.remove(dayIso);

      await _graphqlClient.query(
        _updateTrackingMutation,
        variables: {'id': trackingId, 'tookDates': existing},
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Re-reads [trackingId]'s current `took_dates` (as `YYYY-MM-DD` strings) so
  /// a write can append/remove a single day without racing a stale in-memory
  /// copy.
  Future<List<String>> _currentTookDates({
    required String trackingId,
    required String kitId,
  }) async {
    final current = await _graphqlClient.query(
      _trackingQuery,
      variables: {'kitId': kitId},
    );
    final rows =
        (current['data'] as Map<String, dynamic>?)?['user_integratori']
            as List<dynamic>?;
    final row = rows
        ?.map((j) => UserIntegratoreDto.fromJson(j as Map<String, dynamic>))
        .firstWhere(
          (d) => d.id == trackingId,
          orElse: () => const UserIntegratoreDto(id: ''),
        );
    return row?.tookDates.map(_dateOnly).toList() ?? <String>[];
  }

  /// Formats a date as `YYYY-MM-DD` (the CMS `Date` shape, no time component).
  String _dateOnly(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  String? _titleFor(List<PhaseTranslationDto> translations, String lang) {
    for (final t in translations) {
      if (t.languagesCode?.code == lang) return t.title;
    }
    return translations.firstOrNull?.title;
  }
}
