import 'package:flutter_test/flutter_test.dart';
import 'package:kilocal_flutter_app/features/user/domain/profile_status.dart';

void main() {
  group('ProfileStatus.fromString', () {
    test('maps known backend values', () {
      expect(
        ProfileStatus.fromString('initial_survey'),
        ProfileStatus.initialSurvey,
      );
      expect(ProfileStatus.fromString('type_survey'), ProfileStatus.typeSurvey);
      expect(ProfileStatus.fromString('starter_kit'), ProfileStatus.starterKit);
      expect(ProfileStatus.fromString('active'), ProfileStatus.active);
      expect(
        ProfileStatus.fromString('active_restricted_access'),
        ProfileStatus.activeRestrictedAccess,
      );
      expect(
        ProfileStatus.fromString('qr_pharmacy_1'),
        ProfileStatus.qrPharmacy1,
      );
      expect(
        ProfileStatus.fromString('qr_pharmacy_2'),
        ProfileStatus.qrPharmacy2,
      );
    });

    test('maps unknown or null values to unknown', () {
      expect(ProfileStatus.fromString(null), ProfileStatus.unknown);
      expect(ProfileStatus.fromString(''), ProfileStatus.unknown);
      expect(ProfileStatus.fromString('not_a_status'), ProfileStatus.unknown);
    });
  });

  group('ProfileStatus.isToolBlocked', () {
    test('only active_restricted_access blocks tools', () {
      expect(ProfileStatus.activeRestrictedAccess.isToolBlocked, isTrue);
      expect(ProfileStatus.initialSurvey.isToolBlocked, isFalse);
      expect(ProfileStatus.typeSurvey.isToolBlocked, isFalse);
      expect(ProfileStatus.starterKit.isToolBlocked, isFalse);
      expect(ProfileStatus.active.isToolBlocked, isFalse);
      expect(ProfileStatus.qrPharmacy1.isToolBlocked, isFalse);
      expect(ProfileStatus.qrPharmacy2.isToolBlocked, isFalse);
      expect(ProfileStatus.unknown.isToolBlocked, isFalse);
    });
  });

  group('ProfileStatus.route', () {
    // TODO: revert to '/survey' once the survey APIs are implemented.
    test('temporarily routes survey statuses to /home', () {
      expect(ProfileStatus.initialSurvey.route, '/home');
      expect(ProfileStatus.typeSurvey.route, '/home');
    });

    test('routes active and QR statuses to /home', () {
      expect(ProfileStatus.active.route, '/home');
      expect(ProfileStatus.activeRestrictedAccess.route, '/home');
      expect(ProfileStatus.qrPharmacy1.route, '/home');
      expect(ProfileStatus.qrPharmacy2.route, '/home');
    });

    test('routes starter_kit and unknown to /home as fallback', () {
      expect(ProfileStatus.starterKit.route, '/home');
      expect(ProfileStatus.unknown.route, '/home');
    });
  });
}
