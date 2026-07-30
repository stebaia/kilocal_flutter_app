import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/graphql_client.dart';
import '../../path/domain/entities/barcode_product.dart';
import '../domain/entities/pharmacy.dart';
import '../domain/entities/survey_answer.dart';
import '../domain/entities/survey_outcome.dart';
import '../domain/entities/survey_step.dart';
import '../domain/survey_repository.dart';
import 'survey_mapper.dart';

/// [SurveyRepository] backed by GraphQL (read) + the `survey` REST extension
/// (write). See `wiki/survey.md`.
class SurveyRepositoryImpl implements SurveyRepository {
  SurveyRepositoryImpl({required GraphqlClient graphqlClient, required Dio dio})
    : _graphqlClient = graphqlClient,
      _dio = dio;

  final GraphqlClient _graphqlClient;
  final Dio _dio;

  // CMS language codes are "it-IT" / "en-US". Default to Italian, matching the
  // other repositories (the app's default locale).
  static const _lang = 'it-IT';

  /// The `survey` REST extension requires this origin header on every call.
  static const _originHeader = {'X-Kilocal-Origin': 'app'};

  static const _query = r'''
query GetSurvey($internalName: String!, $lang: String!) {
  surveys(filter: { internal_name: { _eq: $internalName } }, limit: 1) {
    id
    internal_name
    sections(sort: ["sort"]) {
      sort
      survey_sections_id {
        id
        condition_action
        use_custom_cta
        store_in_user_data
        user_data_field_name
        load_kilocal_points
        show_single_product_cta
        single_product_barcode_check
        show_as_dropdown
        small_notification_text
        is_dob_question
        is_gender_question
        is_menopausa_question
        translations(filter: { languages_code: { code: { _eq: $lang } } }) {
          title
          subtitle
          content
        }
        default_cta_translations(
          filter: { languages_code: { code: { _eq: $lang } } }
        ) {
          label
        }
        conditions(sort: ["sort"]) {
          survey_section_conditions_id {
            condition
            simple_value
            value { id }
            values { survey_question_options_id { id } }
          }
        }
        possible_answer {
          id
          type
          input_type
          required
          scale_values
          result_value
          other_validations
          text_translations(
            filter: { languages_code: { code: { _eq: $lang } } }
          ) {
            placeholder
          }
          scale_translations(
            filter: { languages_code: { code: { _eq: $lang } } }
          ) {
            initial_label
            final_label
          }
          options(sort: ["sort"]) {
            survey_question_options_id {
              id
              sort
              is_other
              result_value
              value_to_store
              deselect_others
              translations(
                filter: { languages_code: { code: { _eq: $lang } } }
              ) {
                text
                warning_when_selected
              }
            }
          }
        }
      }
    }
  }
}
''';

  @override
  Future<Survey> fetchSurvey(String internalName) async {
    try {
      final result = await _graphqlClient.query(
        _query,
        variables: <String, dynamic>{
          'internalName': internalName,
          'lang': _lang,
        },
      );

      final data = result['data'] as Map<String, dynamic>?;
      final surveys = data?['surveys'] as List<dynamic>?;
      if (surveys == null || surveys.isEmpty) {
        throw ApiException(
          type: ApiErrorType.notFound,
          statusCode: 404,
          message: 'survey "$internalName" not found',
        );
      }
      return mapSurvey(surveys.first as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  @override
  Future<SurveyStatusInfo> fetchStatus() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/survey/me/status',
        options: Options(headers: _originHeader),
      );
      final data = response.data?['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw const ApiException(
          type: ApiErrorType.unknown,
          statusCode: 200,
          message: 'Empty survey status response',
        );
      }
      return mapStatus(data);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  @override
  Future<SurveyMonthEndPending?> fetchMonthEndStatus() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/survey/me/month-end-status',
        options: Options(headers: _originHeader),
      );
      final data = response.data?['data'] as Map<String, dynamic>?;
      final pending = data?['pending'] as Map<String, dynamic>?;
      // `pending: null` means no month-end survey is due — not an error.
      if (pending == null) return null;
      return mapMonthEndPending(pending);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  @override
  Future<void> ensureDetails() async {
    try {
      await _dio.post<Map<String, dynamic>>(
        '/survey/me/ensure-details',
        options: Options(headers: _originHeader),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  static const _pharmaciesQuery = r'''
query SearchPharmacies($search: String!, $limit: Int!) {
  pharmacies(search: $search, limit: $limit, sort: ["title"]) {
    id
    title
    address
    city
    province
    zip
    region
    store_id
  }
}
''';

  @override
  Future<List<Pharmacy>> searchPharmacies(
    String query, {
    int limit = 20,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];
    try {
      final result = await _graphqlClient.query(
        _pharmaciesQuery,
        variables: <String, dynamic>{'search': trimmed, 'limit': limit},
      );
      final data = result['data'] as Map<String, dynamic>?;
      final rows = data?['pharmacies'] as List<dynamic>? ?? const [];
      return rows.map((e) => mapPharmacy(e as Map<String, dynamic>)).toList();
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// The submit response references the biotype by id only, so the result
  /// screen's copy and images come from `profiles`. `kit.asset.default_asset`
  /// is the real image file — `asset` is only the wrapper (see
  /// [[cms-asset-url-pattern]]).
  static const _outcomeProfileQuery = r'''
query GetOutcomeProfile($id: GraphQLStringOrFloat!, $lang: String!) {
  profiles(filter: { id: { _eq: $id } }, limit: 1) {
    id
    main_color
    secondary_color
    icon { id }
    kit {
      asset {
        default_asset { id }
      }
    }
    translations(filter: { languages_code: { code: { _eq: $lang } } }) {
      title
      name
      content
      content_f
    }
  }
}
''';

  @override
  Future<SurveyOutcome> fetchOutcomeProfile(
    SurveyOutcome outcome, {
    String? gender,
  }) async {
    try {
      final result = await _graphqlClient.query(
        _outcomeProfileQuery,
        variables: <String, dynamic>{'id': outcome.id, 'lang': _lang},
      );
      final rows =
          (result['data'] as Map<String, dynamic>?)?['profiles']
              as List<dynamic>?;
      // A missing profile is not fatal: the result screen degrades to the copy
      // it already has rather than failing the whole submit.
      if (rows == null || rows.isEmpty) return outcome;
      return mapOutcomeProfile(
        outcome,
        rows.first as Map<String, dynamic>,
        gender: gender,
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Flattens every product across a kit's phases (`kit_products`), same shape
  /// as `ProfileKitRepositoryImpl` — no `show_in_shop` filter here since this
  /// is for barcode matching, not the shop listing. There is no
  /// `exclude_from_kit_barcode_check` field in the CMS (confirmed by backend,
  /// 2026-07-28 — it exists on the web front-end only), so every product in
  /// the kit is eligible; `use_for_barcode_check` is a different flow's field
  /// (restricted-access unlock) and is not applied here.
  static const _kitBarcodeProductsQuery = r'''
query KitBarcodeProducts($kitId: ID!) {
  product_kits_by_id(id: $kitId) {
    phases {
      products_with_duration {
        kit_products_duration_id {
          product {
            id
            title
            barcodes
            variants {
              barcodes
            }
          }
        }
      }
    }
  }
}
''';

  @override
  Future<List<BarcodeProduct>> fetchKitBarcodeProducts(String kitId) async {
    try {
      final result = await _graphqlClient.query(
        _kitBarcodeProductsQuery,
        variables: <String, dynamic>{'kitId': kitId},
      );
      final kit =
          (result['data'] as Map<String, dynamic>?)?['product_kits_by_id']
              as Map<String, dynamic>?;
      final phases = kit?['phases'] as List<dynamic>? ?? const [];

      final products = <BarcodeProduct>[];
      final seen = <String>{};
      for (final phase in phases.whereType<Map<String, dynamic>>()) {
        final junctions =
            phase['products_with_duration'] as List<dynamic>? ?? const [];
        for (final junction in junctions.whereType<Map<String, dynamic>>()) {
          final product =
              junction['kit_products_duration_id'] as Map<String, dynamic>?;
          final raw = product?['product'] as Map<String, dynamic>?;
          if (raw == null) continue;
          final id = '${raw['id']}';
          if (!seen.add(id)) continue;
          products.add(_mapKitBarcodeProduct(id, raw));
        }
      }
      return products;
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  BarcodeProduct _mapKitBarcodeProduct(String id, Map<String, dynamic> json) {
    final codes = <String>{
      ..._barcodeCodesFrom(json['barcodes']),
      for (final variant
          in (json['variants'] as List<dynamic>? ?? const [])
              .whereType<Map<String, dynamic>>())
        ..._barcodeCodesFrom(variant['barcodes']),
    };
    return BarcodeProduct(
      id: id,
      title: (json['title'] as String?)?.trim() ?? '',
      codes: codes,
    );
  }

  /// Reads the `codice` values from a `barcodes` JSON field
  /// (`[{ "codice": "A947328593" }]`), normalised to upper case. Same shape as
  /// `ProgramUnlockRepositoryImpl._codesFrom`.
  Iterable<String> _barcodeCodesFrom(dynamic barcodes) sync* {
    if (barcodes is! List) return;
    for (final entry in barcodes) {
      if (entry is Map && entry['codice'] is String) {
        final code = (entry['codice'] as String).trim().toUpperCase();
        if (code.isNotEmpty) yield code;
      }
    }
  }

  @override
  Future<SurveySubmitResult> submit({
    required String internalName,
    required List<SurveyAnswer> answers,
    required Survey survey,
    Pharmacy? pharmacy,
  }) async {
    try {
      final body = buildSubmitBody(
        answers: answers,
        survey: survey,
        pharmacy: pharmacy,
      );
      final response = await _dio.post<Map<String, dynamic>>(
        '/survey/submit/$internalName',
        data: body,
        options: Options(headers: _originHeader),
      );
      final data = response.data?['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw const ApiException(
          type: ApiErrorType.unknown,
          statusCode: 200,
          message: 'Empty survey submit response',
        );
      }
      return mapSubmitResult(data);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
