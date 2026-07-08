import 'package:flutter_test/flutter_test.dart';
import 'package:kilocal_flutter_app/features/path/presentation/widgets/wellbeing_group_style.dart';

void main() {
  group('WellbeingGroupStyle.of', () {
    test('matches by title keyword regardless of position', () {
      expect(
        WellbeingGroupStyle.of('Mindfulness', 2).assetName,
        'assets/mindfulness.png',
      );
      expect(
        WellbeingGroupStyle.of('Self care', 0).assetName,
        'assets/self_care.png',
      );
      expect(
        WellbeingGroupStyle.of('Stili di vita', 0).assetName,
        'assets/lifestyle.png',
      );
    });

    test('falls back to list order for unrecognized titles', () {
      expect(
        WellbeingGroupStyle.of('Sconosciuto', 0).assetName,
        'assets/mindfulness.png',
      );
      expect(
        WellbeingGroupStyle.of('Sconosciuto', 1).assetName,
        'assets/self_care.png',
      );
      expect(
        WellbeingGroupStyle.of('Sconosciuto', 2).assetName,
        'assets/lifestyle.png',
      );
    });

    test('provides a header icon name for each group', () {
      expect(WellbeingGroupStyle.of('Mindfulness', 0).iconName, isNotEmpty);
    });
  });
}
