import 'entities/path_material.dart';

/// Reads the "Materiali extra" hub for an area from the CMS.
abstract class PathMaterialsRepository {
  /// Fetches the materials of the given path group (the area's "Materiali"
  /// group, `is_percorso_main_tab: false`), together with the category tabs
  /// derived from those materials.
  ///
  /// [area] is the clean area key (`alimentazione` / `allenamento` /
  /// `benessere`) required by the REST endpoint that serves these materials.
  /// When it is unknown — a cold deep-link into the hub carries only the group
  /// id — the repository falls back to the GraphQL collection, which is scoped
  /// by group alone but leaves the article→material fallback to the client.
  Future<PathMaterialsData> fetchMaterials({
    required String groupId,
    String? area,
  });

  /// Fetches the full detail (title, HTML body, asset) of a single material.
  /// Returns `null` when the material does not exist.
  Future<PathMaterialDetail?> fetchMaterialDetail({required String id});

  /// Registers the user's completion of a material/article in the diary history.
  ///
  /// Materials have no REST start/complete endpoint (unlike `/path/steps/*`), so
  /// this writes a `user_activities` row directly on the `percorsi_materials`
  /// collection — the same shape the diary Cronologia reads back. Idempotent:
  /// skips the write when the material is already among the user's completed
  /// activities. [userId] is the authenticated Directus user id (`UserCubit.myId`).
  Future<void> markMaterialCompleted({
    required String materialId,
    required String userId,
  });

  /// Computes the completed/total figure for each of the given path groups.
  ///
  /// The Benessere sub-sections carry no steps in the REST `/steps` payload —
  /// their content lives in `percorsi_materials`. So the badge (e.g. 7/21) is
  /// computed here: `total` is the number of materials tied to the group via the
  /// `percorsi_groups_percorsi_materials` junction, and `completed` is how many
  /// of those materials the user has finished (a `user_activities` row on
  /// collection `percorsi_materials` with `completed_on` set).
  ///
  /// Returns a map keyed by group id. Groups with no materials come back as 0/0.
  Future<Map<String, PathGroupProgress>> fetchGroupProgress({
    required List<String> groupIds,
  });
}

/// The completed/total count of a single path group, computed from its
/// materials and the user's completed activities.
class PathGroupProgress {
  const PathGroupProgress({required this.completed, required this.total});

  final int completed;
  final int total;
}
