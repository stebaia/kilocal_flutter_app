import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kilocal_flutter_app/core/network/graphql_client.dart';
import 'package:kilocal_flutter_app/features/survey/data/survey_repository_impl.dart';

/// Captures the outgoing GraphQL body and replays a canned response, so the
/// test can assert on the query text the repository actually sends.
class _CapturingInterceptor extends Interceptor {
  _CapturingInterceptor(this.response);

  final Map<String, dynamic> response;
  Map<String, dynamic>? captured;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    captured = options.data as Map<String, dynamic>;
    handler.resolve(
      Response<Map<String, dynamic>>(
        requestOptions: options,
        statusCode: 200,
        data: response,
      ),
    );
  }
}

SurveyRepositoryImpl _repository(_CapturingInterceptor interceptor) {
  final dio = Dio()..interceptors.add(interceptor);
  return SurveyRepositoryImpl(
    graphqlClient: GraphqlClient(dio: dio),
    dio: dio,
  );
}

void main() {
  // The `#alert#` dialog copy lives in the shared `modals` collection. An
  // earlier version queried a `survey_alerts` collection that does not exist:
  // the read failed, fetchAlertModal() degraded to null, and every `#alert#`
  // option advanced without ever showing its dialog. Nothing else in the
  // feature notices that — hence pinning the collection name here.
  test(
    'fetchAlertModal queries the modals collection by internal_name',
    () async {
      final interceptor = _CapturingInterceptor(<String, dynamic>{
        'data': <String, dynamic>{'modals': <dynamic>[]},
      });

      await _repository(interceptor).fetchAlertModal();

      final body = interceptor.captured!;
      expect(body['query'], contains('modals('));
      expect(body['query'], isNot(contains('survey_alerts')));
      expect(
        (body['variables'] as Map<String, dynamic>)['internalName'],
        'alert_survey_risky_selection_modal',
      );
    },
  );

  test('fetchAlertModal maps the modal title and content', () async {
    final interceptor = _CapturingInterceptor(<String, dynamic>{
      'data': <String, dynamic>{
        'modals': <dynamic>[
          <String, dynamic>{
            'id': '10',
            'translations': <dynamic>[
              <String, dynamic>{
                'title': 'Attenzione',
                'content':
                    '<p>Ti consigliamo di confrontarti con il medico.</p>',
              },
            ],
          },
        ],
      },
    });

    final modal = await _repository(interceptor).fetchAlertModal();

    expect(modal, isNotNull);
    expect(modal!.title, 'Attenzione');
    expect(modal.content, contains('confrontarti con il medico'));
  });

  // A missing CMS row must not trap the user on a step with no dialog to
  // confirm — next() lets them through when this returns null.
  test('fetchAlertModal returns null when the modal is absent', () async {
    final interceptor = _CapturingInterceptor(<String, dynamic>{
      'data': <String, dynamic>{'modals': <dynamic>[]},
    });

    expect(await _repository(interceptor).fetchAlertModal(), isNull);
  });
}
