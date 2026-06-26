import 'entities/momenti_data.dart';

/// Reads editorial "Momenti" content from the CMS.
abstract class MomentiRepository {
  /// Fetches a single moment.
  ///
  /// When [id] is provided the matching moment is returned; otherwise the
  /// currently-active moment (`starts_on <= now <= ends_on`) is used. Returns
  /// `null` when no moment matches.
  Future<MomentiData?> fetchMoment({String? id});
}
