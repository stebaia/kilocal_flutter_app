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
  /// Onboarding drives which CMS survey to open (`internalName`), gated on
  /// `profile_status` (see `wiki/survey.md`):
  /// - `initial_survey` → the initial survey (`type_survey`)
  /// - `starter_kit` → the post-purchase survey (`starter_kit`)
  /// - `qr_pharmacy_1` / `qr_pharmacy_2` → the matching pharmacy survey
  /// - `active`, `active_restricted_access`, `type_survey`, `unknown` → `/home`
  String? get route {
    final survey = surveyInternalName;
    if (survey != null) return '/survey?internalName=$survey';
    return '/home';
  }

  /// The CMS survey `internal_name` the user still has to complete for this
  /// status, or `null` if there is no pending survey (→ `/home`).
  String? get surveyInternalName {
    switch (this) {
      case initialSurvey:
        return 'type_survey';
      case starterKit:
        return 'starter_kit';
      case qrPharmacy1:
        return 'qr_pharmacy_1';
      case qrPharmacy2:
        return 'qr_pharmacy_2';
      case typeSurvey:
      case active:
      case activeRestrictedAccess:
      case unknown:
        return null;
    }
  }
}
