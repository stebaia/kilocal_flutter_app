import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/notification_item.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit({List<NotificationItem>? initialData})
    : super(NotificationsState(items: initialData ?? const []));

  void loadWithData(List<NotificationItem> data) {
    emit(NotificationsState(status: NotificationsStatus.loaded, items: data));
  }

  Future<void> load() async {
    if (state.items.isNotEmpty) {
      emit(state.copyWith(status: NotificationsStatus.loaded));
      return;
    }
    emit(state.copyWith(status: NotificationsStatus.loading));
    // TODO: call repository when backend is ready
  }

  void archive(String id) {
    final updated = state.items.map((item) {
      return item.id == id ? item.copyWith(archived: true) : item;
    }).toList();
    emit(state.copyWith(items: updated));
  }
}
