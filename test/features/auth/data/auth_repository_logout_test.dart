import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retrofit/dio.dart';
import 'package:kilocal_flutter_app/core/network/token_store.dart';
import 'package:kilocal_flutter_app/features/auth/data/auth_api.dart';
import 'package:kilocal_flutter_app/features/auth/data/auth_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthApi extends Mock implements AuthApi {}

class MockTokenStore extends Mock implements TokenStore {}

void main() {
  group('AuthRepositoryImpl.logout', () {
    late MockAuthApi api;
    late MockTokenStore tokenStore;

    setUpAll(() {
      registerFallbackValue(<String, dynamic>{});
    });

    setUp(() {
      api = MockAuthApi();
      tokenStore = MockTokenStore();
      when(() => tokenStore.refreshToken).thenAnswer((_) async => 'refresh-1');
      when(() => tokenStore.clear()).thenAnswer((_) async {});
      when(() => api.logout(any())).thenAnswer(
        (_) async => HttpResponse<void>(
          null,
          Response<void>(requestOptions: RequestOptions(path: '/auth/logout')),
        ),
      );
    });

    test('revokes the push token before clearing the session', () async {
      // The device-token endpoint is bearer-authenticated, so it must be called
      // while the tokens are still stored — otherwise it 401s.
      final calls = <String>[];
      when(() => tokenStore.clear()).thenAnswer((_) async {
        calls.add('clear');
      });

      final repository = AuthRepositoryImpl(
        api: api,
        tokenStore: tokenStore,
        onBeforeLogout: () async => calls.add('unregister-push'),
      );

      await repository.logout();

      expect(calls, ['unregister-push', 'clear']);
    });

    test('logs out normally when no push hook is wired', () async {
      final repository = AuthRepositoryImpl(api: api, tokenStore: tokenStore);

      await repository.logout();

      verify(() => tokenStore.clear()).called(1);
      verify(() => api.logout(any())).called(1);
    });
  });
}
