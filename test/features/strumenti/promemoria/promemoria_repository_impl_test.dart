import 'package:flutter_test/flutter_test.dart';
import 'package:kilocal_flutter_app/features/strumenti/promemoria/data/dto/user_reminder_dto.dart';
import 'package:kilocal_flutter_app/features/strumenti/promemoria/data/promemoria_repository_impl.dart';

void main() {
  group('UserReminderDto.fromJson', () {
    test('parses a /tools/reminders row', () {
      final dto = UserReminderDto.fromJson({
        'id': '3f1c…-uuid',
        'content': 'Bere acqua',
        'due_date': '2026-08-11',
        'due_time': '16:00',
        'completed_at': null,
        'redirectTo': null,
      });

      expect(dto.id, '3f1c…-uuid');
      expect(dto.content, 'Bere acqua');
      expect(dto.dueDate, '2026-08-11');
      expect(dto.dueTime, '16:00');
      expect(dto.completedAt, isNull);
    });

    test('normalizes an int id to string', () {
      final dto = UserReminderDto.fromJson({'id': 42});
      expect(dto.id, '42');
    });

    test('parses the list wrapper', () {
      final res = UserRemindersResponseDto.fromJson({
        'data': [
          {'id': '1', 'content': 'a', 'due_date': '2026-01-01'},
          {'id': '2', 'content': 'b', 'due_date': '2026-01-02'},
        ],
      });
      expect(res.data, hasLength(2));
      expect(res.data.first.id, '1');
    });
  });

  group('PromemoriaRepositoryImpl.parseDateTime', () {
    test('combines due_date and due_time', () {
      expect(
        PromemoriaRepositoryImpl.parseDateTime('2026-08-11', '16:00'),
        DateTime(2026, 8, 11, 16),
      );
    });

    test('tolerates seconds in due_time', () {
      expect(
        PromemoriaRepositoryImpl.parseDateTime('2026-08-11', '16:30:00'),
        DateTime(2026, 8, 11, 16, 30),
      );
    });

    test('defaults missing time to midnight', () {
      expect(
        PromemoriaRepositoryImpl.parseDateTime('2026-08-11', null),
        DateTime(2026, 8, 11),
      );
    });

    test('returns null without a date', () {
      expect(PromemoriaRepositoryImpl.parseDateTime(null, '16:00'), isNull);
      expect(PromemoriaRepositoryImpl.parseDateTime('', '16:00'), isNull);
    });
  });

  group('PromemoriaRepositoryImpl formatters', () {
    test('formatDate is zero-padded YYYY-MM-DD', () {
      expect(
        PromemoriaRepositoryImpl.formatDate(DateTime(2026, 3, 5)),
        '2026-03-05',
      );
    });

    test('formatTime is zero-padded HH:mm', () {
      expect(
        PromemoriaRepositoryImpl.formatTime(DateTime(2026, 3, 5, 9, 7)),
        '09:07',
      );
    });
  });
}
