import 'package:equatable/equatable.dart';

/// A single step entry in the diary **history** (Cronologia).
///
/// Activities are created/advanced by the path (`/path/steps/*`). The list now
/// shows both started-only (no green check) and completed steps; tapping a
/// started-only one opens the detail sheet where it can be completed.
class DiaryActivity extends Equatable {
  const DiaryActivity({
    required this.id,
    required this.area,
    this.stepId,
    this.title,
    this.startedOn,
    this.completedOn,
  });

  final String id;

  /// Id of the linked `percorsi_content` step — the `stepId` passed to
  /// `POST /path/steps/{id}/complete`. Null for activities not backed by a step.
  final String? stepId;

  /// Path root the activity belongs to (`allenamento`, `alimentazione`,
  /// `benessere`, `integrazione`) — drives the coloured category label/icon.
  final DiaryArea area;

  /// Step title/description shown on the card (from the linked `percorsi_content`).
  final String? title;

  final DateTime? startedOn;
  final DateTime? completedOn;

  bool get isCompleted => completedOn != null;

  /// Whether this entry can be completed from the diary (a step, not yet done).
  bool get canComplete => !isCompleted && stepId != null;

  @override
  List<Object?> get props => [id, stepId, area, title, startedOn, completedOn];
}

/// The four fixed path roots. `internalName` matches `root.internal_name`
/// returned by the backend; the diary uses it to pick label/icon/colour.
enum DiaryArea {
  allenamento('allenamento'),
  alimentazione('alimentazione'),
  benessere('benessere'),
  integrazione('integrazione'),
  unknown('');

  const DiaryArea(this.internalName);

  final String internalName;

  static DiaryArea fromInternalName(String? name) {
    for (final area in DiaryArea.values) {
      if (area.internalName == name) return area;
    }
    return DiaryArea.unknown;
  }
}
