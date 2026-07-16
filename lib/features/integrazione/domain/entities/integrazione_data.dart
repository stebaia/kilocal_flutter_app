/// Domain entities for the "Integrazione" (supplements) area.
///
/// Unlike the other three path areas, integrazione advances by **product
/// phases** rather than steps. The kit assigned to the user's profile defines
/// an ordered list of phases; each phase bundles one or more supplements, each
/// with a duration (in days) and a quantity. Daily intake is tracked per
/// supplement via `user_integratori.took_dates`.
class IntegrazioneData {
  const IntegrazioneData({
    required this.phases,
    this.currentPhaseId,
    this.kitId,
  });

  /// Ordered phases of the user's kit (by `phase.sort`).
  final List<IntegrazionePhase> phases;

  /// Id of the phase the user is currently on, or `null` if not started yet.
  final String? currentPhaseId;

  /// Id of the user's kit (needed to write intake tracking).
  final String? kitId;

  /// Index of [currentPhaseId] within [phases], or `-1` when unknown.
  int get currentPhaseIndex => phases.indexWhere((p) => p.id == currentPhaseId);

  bool get hasStarted => currentPhaseId != null;

  /// The index of the first unlocked-but-not-yet-completed phase. When the user
  /// hasn't started, phase 0 is the active one; otherwise it's the current phase.
  int get activeIndex {
    final idx = currentPhaseIndex;
    return idx < 0 ? 0 : idx;
  }

  /// A phase is locked when it comes after the active phase — the user must
  /// complete the earlier phases first ("Completa prima la fase N").
  bool isPhaseLocked(int index) => index > activeIndex;
}

/// A single phase of the supplement plan.
class IntegrazionePhase {
  const IntegrazionePhase({
    required this.id,
    required this.title,
    required this.sort,
    required this.products,
  });

  final String id;
  final String title;
  final int sort;
  final List<IntegrazioneProduct> products;
}

/// A supplement within a phase, with its planned duration and quantity.
class IntegrazioneProduct {
  const IntegrazioneProduct({
    required this.id,
    required this.title,
    required this.durationDays,
    required this.quantity,
    this.imageUrl,
    this.useForBarcodeCheck = false,
    this.instructions,
    this.timing,
    this.description,
    this.avvertenze,
    this.tracking,
  });

  final String id;
  final String title;

  /// Planned duration of intake, in days.
  final int durationDays;

  /// Daily quantity to take.
  final int quantity;

  final String? imageUrl;

  /// Whether this product can unlock the phase via barcode scan.
  final bool useForBarcodeCheck;

  /// HTML usage instructions ("Istruzioni sull'uso") and dosage/timing text.
  final String? instructions;
  final String? timing;

  /// HTML long description and warnings ("avvertenze").
  final String? description;
  final String? avvertenze;

  /// The user's intake tracking for this product, if any exists yet.
  final IntegrazioneTracking? tracking;

  /// Number of days already taken (length of `took_dates`).
  int get takenCount => tracking?.tookDates.length ?? 0;

  /// Whether today has already been marked as taken.
  bool takenToday(DateTime now) =>
      tracking?.tookDates.any((d) => _isSameDay(d, now)) ?? false;

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

/// The user's intake record for a single supplement (`user_integratori`).
class IntegrazioneTracking {
  const IntegrazioneTracking({
    required this.id,
    this.tookDates = const [],
    this.startedOn,
    this.endedOn,
    this.expectedToEndOn,
    this.delayDays,
  });

  /// `user_integratori` row id (null-safe: present only when a record exists).
  final String id;

  /// Days the user marked the supplement as taken.
  final List<DateTime> tookDates;

  final DateTime? startedOn;
  final DateTime? endedOn;
  final DateTime? expectedToEndOn;

  /// Free-text delay indicator from the backend (e.g. days of delay).
  final String? delayDays;
}
