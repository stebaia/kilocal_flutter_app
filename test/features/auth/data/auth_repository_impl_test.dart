import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kilocal_flutter_app/core/network/api_exception.dart';
import 'package:kilocal_flutter_app/core/network/token_store.dart';
import 'package:kilocal_flutter_app/features/auth/data/auth_api.dart';
import 'package:kilocal_flutter_app/features/auth/data/auth_repository_impl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:retrofit/retrofit.dart';

class _MockAuthApi extends Mock implements AuthApi {}

class _MockTokenStore extends Mock implements TokenStore {}

void main() {
  late AuthRepositoryImpl repository;
  late _MockAuthApi api;
  late _MockTokenStore tokenStore;
  bool onLogoutCalled = false;

  setUp(() {
    api = _MockAuthApi();
    tokenStore = _MockTokenStore();
    onLogoutCalled = false;
    repository = AuthRepositoryImpl(
      api: api,
      tokenStore: tokenStore,
      onLogout: () => onLogoutCalled = true,
    );
  });

  group('AuthRepositoryImpl.logout', () {
    test('clears tokens, invokes onLogout and calls the API with refresh token',
        () async {
      const refreshToken = 'refresh-123';

      when(() => tokenStore.refreshToken).thenAnswer((_) async => refreshToken);
      when(() => tokenStore.clear()).thenAnswer((_) async {});
      when(() => api.logout(any(that: isMap)))
          .thenAnswer((_) async => _httpResponse());

      await repository.logout();

      verify(() => tokenStore.clear()).called(1);
      verify(
        () => api.logout({
          'refresh_token': refreshToken,
          'mode': 'json',
        }),
      ).called(1);
      expect(onLogoutCalled, isTrue);
    });

    test('skips API call when there is no refresh token', () async {
      when(() => tokenStore.refreshToken).thenAnswer((_) async => null);
      when(() => tokenStore.clear()).thenAnswer((_) async {});

      await repository.logout();

      verify(() => tokenStore.clear()).called(1);
      verifyNoMoreInteractions(api);
      expect(onLogoutCalled, isTrue);
    });

    test('throws ApiException when the logout request fails', () async {
      const refreshToken = 'refresh-123';

      when(() => tokenStore.refreshToken).thenAnswer((_) async => refreshToken);
      when(() => tokenStore.clear()).thenAnswer((_) async {});
      when(() => api.logout(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/auth/logout'),
          response: Response(
            requestOptions: RequestOptions(path: '/auth/logout'),
            statusCode: 500,
          ),
        ),
      );

      expect(repository.logout(), throwsA(isA<ApiException>()));
    });
  });
}

HttpResponse<void> _httpResponse() {
  return HttpResponse<void>(
    null,
    Response(requestOptions: RequestOptions(path: '/auth/logout')),
  );
}
