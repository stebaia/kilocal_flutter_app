/// Content-gating status stored in `user_details.profile_status`.
///
/// See `wiki/authentication.md` and `wiki/user-session-implementation-plan.md`.
enum ProfileStatus {
  initialSurvey,
  typeSurvey,
  starterKit,
  active,
  activeRestrictedAccess,
  qrPharmacy1,
  qrPharmacy2,
  unknown;

  factory ProfileStatus.fromString(String? value) {
    switch (value) {
      case 'initial_survey':
        return initialSurvey;
      case 'type_survey':
        return typeSurvey;
      case 'starter_kit':
        return starterKit;
      case 'active':
        return active;
      case 'active_restricted_access':
        return activeRestrictedAccess;
      case 'qr_pharmacy_1':
        return qrPharmacy1;
      case 'qr_pharmacy_2':
        return qrPharmacy2;
      default:
        return unknown;
    }
  }

  String? get value {
    switch (this) {
      case initialSurvey:
        return 'initial_survey';
      case typeSurvey:
        return 'type_survey';
      case starterKit:
        return 'starter_kit';
      case active:
        return 'active';
      case activeRestrictedAccess:
        return 'active_restricted_access';
      case qrPharmacy1:
        return 'qr_pharmacy_1';
      case qrPharmacy2:
        return 'qr_pharmacy_2';
      case unknown:
        return null;
    }
  }

  /// Whether tools should be blocked because the user has a restricted profile.
  ///
  /// See `wiki/authentication.md`: tools can be blocked via `is_tool_blocked`
  /// config when `profile_status = active_restricted_access`.
  bool get isToolBlocked => this == activeRestrictedAccess;

  /// The post-login route implied by this status.
  ///
  /// Mapping from `wiki/user-session-implementation-plan.md`:
  /// - `initial_survey`, `type_survey` → `/survey`
  /// - `active`, `active_restricted_access`, `qr_pharmacy_1`, `qr_pharmacy_2`,
  ///   `starter_kit`, `unknown` → `/home`
  ///
  /// TODO: survey APIs and dynamic questions are not implemented yet, so
  /// `initial_survey` / `type_survey` temporarily route to `/home` to allow
  /// testing the rest of the app. Revert to `/survey` once the survey flow is
  /// wired to the CMS.
  String? get route {
    switch (this) {
      case initialSurvey:
      case typeSurvey:
        return '/home';
      case active:
      case activeRestrictedAccess:
      case qrPharmacy1:
      case qrPharmacy2:
      case starterKit:
      case unknown:
        return '/home';
    }
  }
}
