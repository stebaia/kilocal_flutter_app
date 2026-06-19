import '../../../l10n/app_localizations.dart';
import 'entities/path_data.dart';

/// Repository contract for the path screen data.
abstract class PathRepository {
  /// Fetches the data needed to render the path screen.
  ///
  /// [l10n] is used to localize the fallback/mock data until the backend
  /// returns already-localized content.
  Future<PathData> fetchPath(AppLocalizations l10n);
}
