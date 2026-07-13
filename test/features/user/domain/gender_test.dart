import 'package:flutter_test/flutter_test.dart';
import 'package:kilocal_flutter_app/features/user/domain/user_details.dart';

void main() {
  group('genderIsFemale', () {
    test('the survey-stored "f" is female (any case)', () {
      expect(genderIsFemale('f'), isTrue);
      expect(genderIsFemale('F'), isTrue);
    });

    test('"m", "other", null and unknown are non-female', () {
      expect(genderIsFemale('m'), isFalse);
      expect(genderIsFemale('other'), isFalse);
      expect(genderIsFemale(null), isFalse);
      expect(genderIsFemale(''), isFalse);
      // Values the backend never sends must not accidentally read as female.
      expect(genderIsFemale('female'), isFalse);
    });
  });

  group('UserDetails.isFemale', () {
    test('mirrors genderIsFemale on the gender field', () {
      expect(const UserDetails(gender: 'f').isFemale, isTrue);
      expect(const UserDetails(gender: 'm').isFemale, isFalse);
      expect(const UserDetails(gender: 'other').isFemale, isFalse);
      expect(const UserDetails().isFemale, isFalse);
    });
  });
}
