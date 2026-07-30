import 'package:flutter_test/flutter_test.dart';
import 'package:kilocal_flutter_app/features/user/data/dto/user_details_dto.dart';

void main() {
  group('UserDetailsDto.fromJson allergie/intolleranze/dieta', () {
    test('parses a normal list of values', () {
      final dto = UserDetailsDto.fromJson({
        'allergie': ['nichel', 'lattosio'],
        'intolleranze': ['glutine'],
        'dieta': ['vegetariana'],
      });

      expect(dto.allergie, ['nichel', 'lattosio']);
      expect(dto.intolleranze, ['glutine']);
      expect(dto.dieta, ['vegetariana']);
    });

    test('drops literal null entries instead of stringifying them', () {
      final dto = UserDetailsDto.fromJson({
        'allergie': [null],
        'intolleranze': [null],
        'dieta': [null],
      });

      expect(dto.allergie, isEmpty);
      expect(dto.intolleranze, isEmpty);
      expect(dto.dieta, isEmpty);
    });

    test('drops null entries mixed with real values', () {
      final dto = UserDetailsDto.fromJson({
        'allergie': ['nichel', null],
      });

      expect(dto.allergie, ['nichel']);
    });

    test('treats a fully-null field as null, not an empty list', () {
      final dto = UserDetailsDto.fromJson({'allergie': null});

      expect(dto.allergie, isNull);
    });
  });
}
