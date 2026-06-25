import '../../../l10n/app_localizations.dart';
import 'entities/path_area_detail.dart';
import 'entities/path_data.dart';

/// Repository contract for the path screen data.
abstract class PathRepository {
  /// Fetches the data needed to render the path overview screen.
  Future<PathData> fetchPath(AppLocalizations l10n);

  /// Fetches the detail of a single area, grouped by timeframe.
  Future<PathAreaDetail> fetchAreaSteps({
    required String area,
    required AppLocalizations l10n,
  });

  /// Starts a step.
  Future<void> startStep(String stepId);

  /// Completes a step. [area] is the clean area key (`allenamento`, etc.).
  Future<void> completeStep({required String stepId, required String area});
}
