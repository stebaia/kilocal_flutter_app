import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/network/api_exception.dart';
import '../../../user/presentation/cubit/user_cubit.dart';
import '../../domain/entities/notification_item.dart';
import '../../domain/notifications_repository.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit({
    required NotificationsRepository notificationsRepository,
    required UserCubit userCubit,
  }) : _notificationsRepository = notificationsRepository,
       _userCubit = userCubit,
       super(const NotificationsState());

  final NotificationsRepository _notificationsRepository;
  final UserCubit _userCubit;

  void loadWithData(List<NotificationItem> data) {
    emit(NotificationsState(status: NotificationsStatus.loaded, items: data));
  }

  Future<void> load() async {
    emit(state.copyWith(status: NotificationsStatus.loading, error: null));

    final user = _userCubit.state.user;
    if (user == null) {
      emit(
        state.copyWith(
          status: NotificationsStatus.error,
          error: const ApiException(
            type: ApiErrorType.unknown,
            statusCode: 200,
            message: 'User session not loaded',
          ),
        ),
      );
      return;
    }

    try {
      final items = await _notificationsRepository.fetchNotifications(
        myId: user.id,
        archived: state.filter == NotificationFilter.archived,
      );
      emit(state.copyWith(status: NotificationsStatus.loaded, items: items));
    } on ApiException catch (e) {
      emit(state.copyWith(status: NotificationsStatus.error, error: e));
    }
  }

  Future<void> setFilter(NotificationFilter filter) async {
    if (filter == state.filter) return;
    emit(state.copyWith(filter: filter, items: const []));
    await load();
  }

  Future<void> archive(String id) async {
    final previous = state.items;
    _optimisticallyUpdate(id, archived: true);

    try {
      await _notificationsRepository.archive(id);
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          items: previous,
          status: NotificationsStatus.error,
          error: e,
        ),
      );
    }
  }

  Future<void> markRead(String id) async {
    final item = state.items.firstWhere((i) => i.id == id);
    if (item.read) return;

    final previous = state.items;
    _optimisticallyUpdate(id, read: true);

    try {
      await _notificationsRepository.markRead(id);
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          items: previous,
          status: NotificationsStatus.error,
          error: e,
        ),
      );
    }
  }

  void _optimisticallyUpdate(String id, {bool? archived, bool? read}) {
    final updated = state.items.map((item) {
      if (item.id != id) return item;
      return item.copyWith(archived: archived, read: read);
    }).toList();
    emit(state.copyWith(items: updated));
  }
}
