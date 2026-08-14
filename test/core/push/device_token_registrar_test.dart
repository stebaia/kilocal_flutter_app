import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kilocal_flutter_app/core/push/device_token_api.dart';
import 'package:kilocal_flutter_app/core/push/device_token_registrar.dart';
import 'package:kilocal_flutter_app/core/push/push_notification_service.dart';
import 'package:mocktail/mocktail.dart';

class MockDeviceTokenApi extends Mock implements DeviceTokenApi {}

class MockPushNotificationService extends Mock
    implements PushNotificationService {}

void main() {
  group('DeviceTokenRegistrar', () {
    late MockDeviceTokenApi api;
    late MockPushNotificationService push;
    late StreamController<String> tokenRefresh;
    late DeviceTokenRegistrar registrar;

    setUpAll(() {
      registerFallbackValue(<String, dynamic>{});
    });

    setUp(() {
      api = MockDeviceTokenApi();
      push = MockPushNotificationService();
      tokenRefresh = StreamController<String>.broadcast();

      when(() => push.onTokenRefresh).thenAnswer((_) => tokenRefresh.stream);
      when(() => push.getToken()).thenAnswer((_) async => 'token-1');
      when(() => api.register(any())).thenAnswer((_) async {});
      when(() => api.unregister(any())).thenAnswer((_) async {});

      registrar = DeviceTokenRegistrar(
        api: api,
        push: push,
        platformOverride: TargetPlatform.iOS,
      );
    });

    tearDown(() async {
      await registrar.dispose();
      await tokenRefresh.close();
    });

    test('registers the current token with the platform name', () async {
      await registrar.registerCurrentToken();

      verify(
        () => api.register({'token': 'token-1', 'platform': 'ios'}),
      ).called(1);
    });

    test('maps Android to the android platform', () async {
      final android = DeviceTokenRegistrar(
        api: api,
        push: push,
        platformOverride: TargetPlatform.android,
      );
      addTearDown(android.dispose);

      await android.registerCurrentToken();

      verify(
        () => api.register({'token': 'token-1', 'platform': 'android'}),
      ).called(1);
    });

    test('skips registration when FCM has no token', () async {
      when(() => push.getToken()).thenAnswer((_) async => null);

      await registrar.registerCurrentToken();

      verifyNever(() => api.register(any()));
    });

    test('registers a rotated token while the session is active', () async {
      await registrar.registerCurrentToken();

      tokenRefresh.add('token-2');
      await pumpEventQueue();

      verify(
        () => api.register({'token': 'token-2', 'platform': 'ios'}),
      ).called(1);
    });

    test('ignores a rotated token after logout', () async {
      await registrar.registerCurrentToken();
      await registrar.unregisterCurrentToken();
      clearInteractions(api);

      tokenRefresh.add('token-2');
      await pumpEventQueue();

      verifyNever(() => api.register(any()));
    });

    test('unregisters the token without the platform field', () async {
      await registrar.registerCurrentToken();
      await registrar.unregisterCurrentToken();

      verify(() => api.unregister({'token': 'token-1'})).called(1);
    });

    test('unregisters the token last registered, not a rotated one', () async {
      await registrar.registerCurrentToken();
      // FCM starts returning a new token, but the backend only knows the old
      // one until the refresh event lands.
      when(() => push.getToken()).thenAnswer((_) async => 'token-2');

      await registrar.unregisterCurrentToken();

      verify(() => api.unregister({'token': 'token-1'})).called(1);
    });

    test('swallows a failing registration', () async {
      when(
        () => api.register(any()),
      ).thenThrow(DioException(requestOptions: RequestOptions(path: '/')));

      await expectLater(registrar.registerCurrentToken(), completes);
    });

    test('swallows a 404 on unregister so logout still proceeds', () async {
      await registrar.registerCurrentToken();
      when(() => api.unregister(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/'),
          response: Response(
            requestOptions: RequestOptions(path: '/'),
            statusCode: 404,
          ),
        ),
      );

      await expectLater(registrar.unregisterCurrentToken(), completes);
    });

    test('swallows a failing getToken', () async {
      when(() => push.getToken()).thenThrow(Exception('APNs unavailable'));

      await expectLater(registrar.registerCurrentToken(), completes);
      verifyNever(() => api.register(any()));
    });
  });
}
