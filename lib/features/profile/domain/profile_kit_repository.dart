import 'entities/profile_kit.dart';

/// Loads the user's kit ("Il mio Kit") with its plan copy and supplement
/// products, for the two product cards on the biotype detail screen.
abstract class ProfileKitRepository {
  /// Fetches the kit with [kitId], resolving its plan translation and products
  /// in [lang]. Returns `null` when the kit does not exist.
  Future<ProfileKit?> fetchKit({required String kitId, required String lang});
}
