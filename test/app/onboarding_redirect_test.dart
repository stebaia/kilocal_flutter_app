import 'package:flutter_test/flutter_test.dart';
import 'package:kilocal_flutter_app/app/router.dart';
import 'package:kilocal_flutter_app/features/user/domain/profile_status.dart';

/// Guards the onboarding gate: while `profile_status` names a pending survey,
/// the user must not reach the rest of the app.
///
/// After `type_survey` the backend moves the user to `starter_kit` — the
/// post-purchase survey holding the barcode step — so finishing the initial
/// survey must not land on /home without a proof of purchase.
void main() {
  String? redirect({
    required ProfileStatus status,
    required String path,
    bool sessionLoaded = true,
  }) {
    return onboardingRedirectFor(
      sessionLoaded: sessionLoaded,
      pendingSurvey: status.surveyInternalName,
      path: path,
    );
  }

  group('with a pending starter_kit survey', () {
    test('forces the proof-of-purchase survey from anywhere in the app', () {
      for (final path in ['/home', '/path', '/benefits', '/statistics']) {
        expect(
          redirect(status: ProfileStatus.starterKit, path: path),
          '/survey?internalName=starter_kit',
          reason: '$path must not be reachable before the starter kit survey',
        );
      }
    });

    test('lets the survey itself through', () {
      expect(redirect(status: ProfileStatus.starterKit, path: '/survey'), null);
    });

    test('lets the auth flow through', () {
      for (final path in [
        '/splash',
        '/onboarding',
        '/login',
        '/signup',
        '/forgot-password',
      ]) {
        expect(
          redirect(status: ProfileStatus.starterKit, path: path),
          null,
          reason: '$path must stay reachable',
        );
      }
    });
  });

  test('sends an initial_survey user to the type survey', () {
    expect(
      redirect(status: ProfileStatus.initialSurvey, path: '/home'),
      '/survey?internalName=type_survey',
    );
  });

  test('does not gate a user with no pending survey', () {
    for (final status in [
      ProfileStatus.active,
      ProfileStatus.activeRestrictedAccess,
      ProfileStatus.typeSurvey,
      ProfileStatus.unknown,
    ]) {
      expect(
        redirect(status: status, path: '/home'),
        null,
        reason: '$status has no pending survey',
      );
    }
  });

  test('does not gate before the session is loaded', () {
    // Redirecting on a not-yet-loaded session would bounce the user off /login.
    expect(
      redirect(
        status: ProfileStatus.starterKit,
        path: '/home',
        sessionLoaded: false,
      ),
      null,
    );
  });
}
