import 'entities/path_material.dart';

/// Reads the "Materiali extra" hub for an area from the CMS.
abstract class PathMaterialsRepository {
  /// Fetches the materials of the given path group (the area's "Materiali"
  /// group, `is_percorso_main_tab: false`), together with the category tabs
  /// derived from those materials.
  Future<PathMaterialsData> fetchMaterials({required String groupId});

  /// Fetches the full detail (title, HTML body, asset) of a single material.
  /// Returns `null` when the material does not exist.
  Future<PathMaterialDetail?> fetchMaterialDetail({required String id});
}
