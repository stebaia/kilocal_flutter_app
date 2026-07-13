import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kilocal_flutter_app/features/profile/data/biotype_texts_loader.dart';

void main() {
  // The loader reads the real bundled asset, so tests exercise the actual data.
  TestWidgetsFlutterBinding.ensureInitialized();

  final loader = BiotypeTextsLoader();

  test('loads man type 1 with 4 points and 4 areas', () async {
    final texts = await loader.forBiotype(number: 1, isFemale: false);
    expect(texts, isNotNull);
    expect(texts!.points, hasLength(4));
    expect(texts.areas.keys, containsAll(<String>[
      'allenamento',
      'alimentazione',
      'benessere',
      'integrazione',
    ]));
  });

  test('point 0 is the head text (title + non-empty body)', () async {
    final texts = await loader.forBiotype(number: 1, isFemale: false);
    final head = texts!.points.first;
    expect(head.zone, 'TESTA');
    expect(head.title, isNotEmpty);
    expect(head.body, isNotEmpty);
  });

  test('woman type 1 has 5 points; type 5 exists only for woman', () async {
    final w1 = await loader.forBiotype(number: 1, isFemale: true);
    expect(w1!.points, hasLength(5));

    final w5 = await loader.forBiotype(number: 5, isFemale: true);
    expect(w5, isNotNull);
    expect(w5!.points, hasLength(4));
  });

  test('woman type 1 addome body matches the source copy', () async {
    final texts = await loader.forBiotype(number: 1, isFemale: true);
    final addome =
        texts!.points.firstWhere((p) => p.zone == 'ADDOME SUL FIANCO');
    expect(addome.title, 'Addome e zona epatica');
    expect(addome.body, contains('gonfiore e pesantezza'));
  });

  test('unknown type / null number → null', () async {
    expect(await loader.forBiotype(number: 99, isFemale: false), isNull);
    expect(await loader.forBiotype(number: null, isFemale: false), isNull);
  });
}
