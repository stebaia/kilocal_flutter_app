import 'entities/benefit.dart';

/// Contract for loading partner benefits.
abstract class BenefitsRepository {
  /// Fetches all partner benefits, sorted by name.
  Future<List<Benefit>> fetchBenefits();
}
