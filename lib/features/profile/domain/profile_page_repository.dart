import 'entities/profile_page.dart';

/// Reads CMS-driven profile pages (`private_pages`) by their `internal_name`.
abstract interface class ProfilePageRepository {
  /// Fetches the page with the given [internalName] (e.g. `dashboard-type`),
  /// resolving its builder sections. Throws `ApiException` on failure.
  Future<ProfilePage> fetchPage(String internalName);
}
