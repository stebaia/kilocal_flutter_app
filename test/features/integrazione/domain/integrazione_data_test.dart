import 'package:flutter_test/flutter_test.dart';
import 'package:kilocal_flutter_app/features/integrazione/domain/entities/integrazione_data.dart';

void main() {
  IntegrazionePhase phase(String id) => IntegrazionePhase(
    id: id,
    title: 'Fase $id',
    sort: int.parse(id),
    products: const [],
  );

  group('IntegrazioneData', () {
    test('hasStarted is false and index is -1 when no current phase', () {
      final data = IntegrazioneData(phases: [phase('1'), phase('2')]);
      expect(data.hasStarted, isFalse);
      expect(data.currentPhaseIndex, -1);
    });

    test('resolves the current phase index', () {
      final data = IntegrazioneData(
        phases: [phase('1'), phase('2'), phase('3')],
        currentPhaseId: '2',
      );
      expect(data.hasStarted, isTrue);
      expect(data.currentPhaseIndex, 1);
    });

    test('index is -1 when current phase id is absent from the list', () {
      final data = IntegrazioneData(phases: [phase('1')], currentPhaseId: '99');
      expect(data.currentPhaseIndex, -1);
    });

    test('when not started, phase 0 is active and later phases are locked', () {
      final data = IntegrazioneData(
        phases: [phase('1'), phase('2'), phase('3')],
      );
      expect(data.activeIndex, 0);
      expect(data.isPhaseLocked(0), isFalse);
      expect(data.isPhaseLocked(1), isTrue);
      expect(data.isPhaseLocked(2), isTrue);
    });

    test('phases up to and including the current one are unlocked', () {
      final data = IntegrazioneData(
        phases: [phase('1'), phase('2'), phase('3')],
        currentPhaseId: '2',
      );
      expect(data.activeIndex, 1);
      expect(data.isPhaseLocked(0), isFalse);
      expect(data.isPhaseLocked(1), isFalse);
      expect(data.isPhaseLocked(2), isTrue);
    });
  });

  group('IntegrazioneProduct intake', () {
    IntegrazioneProduct product({IntegrazioneTracking? tracking}) =>
        IntegrazioneProduct(
          id: '7',
          title: 'X',
          durationDays: 14,
          quantity: 1,
          tracking: tracking,
        );

    test('takenCount is 0 and takenToday is false without tracking', () {
      final p = product();
      expect(p.takenCount, 0);
      expect(p.takenToday(DateTime(2026, 7, 6)), isFalse);
    });

    test('takenToday matches on the same calendar day, ignoring time', () {
      final p = product(
        tracking: IntegrazioneTracking(
          id: '1',
          tookDates: [DateTime(2026, 7, 6, 8, 30), DateTime(2026, 7, 5)],
        ),
      );
      expect(p.takenCount, 2);
      expect(p.takenToday(DateTime(2026, 7, 6, 22, 0)), isTrue);
      expect(p.takenToday(DateTime(2026, 7, 7)), isFalse);
    });
  });
}
