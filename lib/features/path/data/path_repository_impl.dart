import '../../../l10n/app_localizations.dart';
import '../domain/entities/path_data.dart';
import '../domain/path_repository.dart';
import 'path_mock_data_factory.dart';

/// Repository implementation that loads the path data from the backend.
///
/// Currently this falls back to a localized dataset because the dedicated path
/// GraphQL fields are not wired yet. The fallback lives here instead of inside
/// the UI so the screen remains free of hard-coded values.
class PathRepositoryImpl implements PathRepository {
  const PathRepositoryImpl();

  @override
  Future<PathData> fetchPath(AppLocalizations l10n) async {
    // TODO: replace the fallback with a real GraphQL query once the path CMS
    // collection is available.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return PathMockDataFactory.build(l10n);
  }
}
