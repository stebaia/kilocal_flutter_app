import 'package:equatable/equatable.dart';

/// A single completed-step entry in the diary **history** (Cronologia).
///
/// Read-only: activities are created/completed by the path (`/path/steps/*`),
/// the diary only reads them from `user_activities` via GraphQL.
class DiaryActivity extends Equatable {
  const DiaryActivity({
    required this.id,
    required this.area,
    this.title,
    this.startedOn,
    this.completedOn,
  });

  final String id;

  /// Path root the activity belongs to (`allenamento`, `alimentazione`,
  /// `benessere`, `integrazione`) — drives the coloured category label/icon.
  final DiaryArea area;

  /// Step title/description shown on the card (from the linked `percorsi_content`).
  final String? title;

  final DateTime? startedOn;
  final DateTime? completedOn;

  bool get isCompleted => completedOn != null;

  @override
  List<Object?> get props => [id, area, title, startedOn, completedOn];
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
