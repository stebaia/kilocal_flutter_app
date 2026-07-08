import 'package:flutter_test/flutter_test.dart';
import 'package:kilocal_flutter_app/features/integrazione/domain/entities/reminder_offset.dart';

void main() {
  group('ReminderOffset', () {
    test('durations match the snooze options', () {
      expect(ReminderOffset.hours2.duration, const Duration(hours: 2));
      expect(ReminderOffset.hours4.duration, const Duration(hours: 4));
      expect(ReminderOffset.hours8.duration, const Duration(hours: 8));
      expect(ReminderOffset.day1.duration, const Duration(days: 1));
    });

    test('round-trips through its payload key', () {
      for (final o in ReminderOffset.values) {
        expect(ReminderOffset.fromKey(o.key), o);
      }
    });

    test('fromKey returns null for unknown/empty keys', () {
      expect(ReminderOffset.fromKey('nope'), isNull);
      expect(ReminderOffset.fromKey(null), isNull);
      expect(ReminderOffset.fromKey(''), isNull);
    });
  });
}
