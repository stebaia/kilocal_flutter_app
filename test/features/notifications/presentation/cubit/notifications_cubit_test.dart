import 'package:flutter_test/flutter_test.dart';
import 'package:kilocal_flutter_app/core/network/api_exception.dart';
import 'package:kilocal_flutter_app/features/notifications/domain/entities/notification_item.dart';
import 'package:kilocal_flutter_app/features/notifications/domain/notifications_repository.dart';
import 'package:kilocal_flutter_app/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:kilocal_flutter_app/features/user/domain/app_user.dart';
import 'package:kilocal_flutter_app/features/user/presentation/cubit/user_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationsRepository extends Mock
    implements NotificationsRepository {}

class MockUserCubit extends Mock implements UserCubit {}

void main() {
  group('NotificationsCubit', () {
    late MockNotificationsRepository repository;
    late MockUserCubit userCubit;
    late NotificationsCubit cubit;

    const user = AppUser(id: 'user-1');
    final now = DateTime(2026, 6, 19);
    final item = NotificationItem(
      id: '1',
      title: 'Title',
      body: 'Body',
      timestamp: now,
    );

    setUp(() {
      repository = MockNotificationsRepository();
      userCubit = MockUserCubit();
      when(
        () => userCubit.state,
      ).thenReturn(const UserState(user: user, status: UserStatus.loaded));
      cubit = NotificationsCubit(
        notificationsRepository: repository,
        userCubit: userCubit,
      );
    });

    test('initial state is empty', () {
      expect(cubit.state.status, NotificationsStatus.initial);
      expect(cubit.state.items, isEmpty);
    });

    test('load emits loaded items on success', () async {
      when(
        () => repository.fetchNotifications(
          myId: user.id,
          archived: any(named: 'archived'),
        ),
      ).thenAnswer((_) async => [item]);

      final future = cubit.load();
      expect(cubit.state.status, NotificationsStatus.loading);

      await future;

      expect(cubit.state.status, NotificationsStatus.loaded);
      expect(cubit.state.items, [item]);
      verify(
        () => repository.fetchNotifications(
          myId: user.id,
          archived: any(named: 'archived'),
        ),
      ).called(1);
    });

    test('load emits error when user is not loaded', () async {
      when(() => userCubit.state).thenReturn(const UserState());
      cubit = NotificationsCubit(
        notificationsRepository: repository,
        userCubit: userCubit,
      );

      await cubit.load();

      expect(cubit.state.status, NotificationsStatus.error);
      expect(cubit.state.error, isNotNull);
    });

    test(
      'archive removes item optimistically and keeps it removed on success',
      () async {
        cubit.emit(
          NotificationsState(status: NotificationsStatus.loaded, items: [item]),
        );
        when(() => repository.archive(item.id)).thenAnswer((_) async {});

        await cubit.archive(item.id);

        expect(cubit.state.items.first.archived, true);
        verify(() => repository.archive(item.id)).called(1);
      },
    );

    test('archive rolls back on repository failure', () async {
      cubit.emit(
        NotificationsState(status: NotificationsStatus.loaded, items: [item]),
      );
      when(() => repository.archive(item.id)).thenThrow(
        const ApiException(type: ApiErrorType.server, statusCode: 500),
      );

      await cubit.archive(item.id);

      expect(cubit.state.items.first.archived, false);
      expect(cubit.state.status, NotificationsStatus.error);
    });

    test('markRead sets read optimistically and keeps it on success', () async {
      cubit.emit(
        NotificationsState(status: NotificationsStatus.loaded, items: [item]),
      );
      when(() => repository.markRead(item.id)).thenAnswer((_) async {});

      await cubit.markRead(item.id);

      expect(cubit.state.items.first.read, true);
      verify(() => repository.markRead(item.id)).called(1);
    });

    test('markRead rolls back on repository failure', () async {
      cubit.emit(
        NotificationsState(status: NotificationsStatus.loaded, items: [item]),
      );
      when(() => repository.markRead(item.id)).thenThrow(
        const ApiException(type: ApiErrorType.server, statusCode: 500),
      );

      await cubit.markRead(item.id);

      expect(cubit.state.items.first.read, false);
      expect(cubit.state.status, NotificationsStatus.error);
    });
  });
}
