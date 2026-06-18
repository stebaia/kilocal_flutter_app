import 'package:flutter_test/flutter_test.dart';
import 'package:kilocal_flutter_app/features/home/data/home_repository_impl.dart';

void main() {
  group('HomeRepositoryImpl.computeProgress', () {
    test('returns 0 when total is 0', () {
      expect(HomeRepositoryImpl.computeProgress(5, 0), 0.0);
    });

    test('returns 0 when nothing is completed', () {
      expect(HomeRepositoryImpl.computeProgress(0, 10), 0.0);
    });

    test('returns completed / total', () {
      expect(HomeRepositoryImpl.computeProgress(4, 10), 0.4);
      expect(HomeRepositoryImpl.computeProgress(10, 10), 1.0);
      expect(HomeRepositoryImpl.computeProgress(3, 12), 0.25);
    });
  });
}
