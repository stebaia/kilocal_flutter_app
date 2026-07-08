import 'package:flutter_test/flutter_test.dart';
import 'package:kilocal_flutter_app/features/integrazione/data/dto/integrazione_dto.dart';

void main() {
  group('KitProductDto.fromJson', () {
    // Shape captured live from cms-stg (kit id=3), see integrazione-schema.
    final json = {
      'id': '5',
      'sort': null,
      'only_for_gender': null,
      'phase': {
        'id': '1',
        'sort': 1,
        'translations': [
          {
            'languages_code': {'code': 'it-IT'},
            'title': 'Fase 1',
          },
        ],
      },
      'products_with_duration': [
        {
          'kit_products_duration_id': {
            'id': '5',
            'duration': 20,
            'quantity': 1,
            'product': {
              'id': '7',
              'title': 'Kilocal Drenante Forte',
              'use_for_barcode_check': true,
              'asset': {'id': '1377'},
            },
          },
        },
      ],
    };

    test('parses the phase, translation and nested product+duration', () {
      final dto = KitProductDto.fromJson(json);

      expect(dto.id, '5');
      expect(dto.phase?.id, '1');
      expect(dto.phase?.sort, 1);
      expect(dto.phase?.translations.single.title, 'Fase 1');
      expect(dto.phase?.translations.single.languagesCode?.code, 'it-IT');

      final entry = dto.productsWithDuration.single.durationEntry;
      expect(entry?.duration, 20);
      expect(entry?.quantity, 1);
      expect(entry?.product?.id, '7');
      expect(entry?.product?.title, 'Kilocal Drenante Forte');
      expect(entry?.product?.useForBarcodeCheck, isTrue);
      expect(entry?.product?.asset?.id, '1377');
    });

    test('coerces int ids to strings', () {
      final dto = KitProductDto.fromJson({...json, 'id': 5});
      expect(dto.id, '5');
    });

    test('tolerates an empty products list', () {
      final dto = KitProductDto.fromJson({
        ...json,
        'products_with_duration': <dynamic>[],
      });
      expect(dto.productsWithDuration, isEmpty);
    });
  });
}
