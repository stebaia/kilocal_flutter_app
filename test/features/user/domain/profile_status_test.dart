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
    test('routes pending-survey statuses to the matching CMS survey', () {
      expect(
        ProfileStatus.initialSurvey.route,
        '/survey?internalName=type_survey',
      );
      expect(
        ProfileStatus.starterKit.route,
        '/survey?internalName=starter_kit',
      );
      expect(
        ProfileStatus.qrPharmacy1.route,
        '/survey?internalName=qr_pharmacy_1',
      );
      expect(
        ProfileStatus.qrPharmacy2.route,
        '/survey?internalName=qr_pharmacy_2',
      );
    });

    test('routes completed / active statuses to /home', () {
      expect(ProfileStatus.typeSurvey.route, '/home');
      expect(ProfileStatus.active.route, '/home');
      expect(ProfileStatus.activeRestrictedAccess.route, '/home');
      expect(ProfileStatus.unknown.route, '/home');
    });

    test('surveyInternalName exposes the pending survey (or null)', () {
      expect(ProfileStatus.initialSurvey.surveyInternalName, 'type_survey');
      expect(ProfileStatus.starterKit.surveyInternalName, 'starter_kit');
      expect(ProfileStatus.active.surveyInternalName, isNull);
    });
  });
}
