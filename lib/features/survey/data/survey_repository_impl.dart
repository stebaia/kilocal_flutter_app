import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/graphql_client.dart';
import '../domain/entities/pharmacy.dart';
import '../domain/entities/survey_answer.dart';
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
