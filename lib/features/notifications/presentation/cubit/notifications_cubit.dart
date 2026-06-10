import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'notifications_state.dart';

enum NotificationType { plain, withImage, withCta }

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.type = NotificationType.plain,
    this.imageUrl,
    this.ctaLabel,
    this.archived = false,
  });

  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final NotificationType type;
  final String? imageUrl;
  final String? ctaLabel;
  final bool archived;
}

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit() : super(const NotificationsState());

  Future<void> load() async {
    emit(state.copyWith(status: NotificationsStatus.loading));
    await Future<void>.delayed(const Duration(milliseconds: 500));
    emit(
      state.copyWith(
        status: NotificationsStatus.loaded,
        items: [
          NotificationItem(
            id: '1',
            title: 'Nuovo allenamento disponibile',
            body: 'Hai un nuovo allenamento per oggi!',
            timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
            type: NotificationType.withCta,
            ctaLabel: 'Inizia',
          ),
          NotificationItem(
            id: '2',
            title: 'Promemoria pasto',
            body: 'Non dimenticare il tuo spuntino delle 16:00.',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          NotificationItem(
            id: '3',
            title: 'Nuovo benefit attivo',
            body: 'Scopri il nuovo codice sconto per Spotify.',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            type: NotificationType.withImage,
            imageUrl: 'https://placehold.co/80x80/e51e4d/ffffff?text=SP',
          ),
          NotificationItem(
            id: '4',
            title: 'Survey completata',
            body: 'Grazie per aver completato il survey iniziale.',
            timestamp: DateTime.now().subtract(const Duration(days: 2)),
          ),
        ],
      ),
    );
  }

  void archive(String id) {
    final updated = state.items.map((item) {
      return item.id == id ? item.copyWith(archived: true) : item;
    }).toList();
    emit(state.copyWith(items: updated));
  }
}

extension on NotificationItem {
  NotificationItem copyWith({bool? archived}) {
    return NotificationItem(
      id: id,
      title: title,
      body: body,
      timestamp: timestamp,
      type: type,
      imageUrl: imageUrl,
      ctaLabel: ctaLabel,
      archived: archived ?? this.archived,
    );
  }
}