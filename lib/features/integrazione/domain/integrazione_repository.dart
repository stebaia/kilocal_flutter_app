import 'entities/integrazione_data.dart';

/// Read/write access to the "Integrazione" (supplements) area.
///
/// Everything here is backed by GraphQL ([[integrazione]]); it does NOT use the
/// `/path/me/areas/*/steps` REST endpoint (that rejects `integrazione` with a
/// 400). Advancement is by product phase.
abstract class IntegrazioneRepository {
  /// Loads the user's supplement plan (phases + products) for their kit, along
  /// with the current phase. [lang] is a CMS language code such as `it-IT`.
  Future<IntegrazioneData> fetchIntegrazione({
    required String myId,
    required String lang,
  });

  /// Advances the user to [phaseId] by updating
  /// `user_details.percorso_integrazione_curr_phase`.
  Future<void> setCurrentPhase({
    required String userDetailsId,
    required String phaseId,
  });

  /// Marks [day] as taken for [productId] within [kitId], appending it to the
  /// `user_integratori.took_dates` array. Creates the `user_integratori` record
  /// on first use (when [trackingId] is null), otherwise updates it. Returns the
  /// updated tracking.
  Future<void> markTaken({
    required String myId,
    required String productId,
    required String kitId,
    String? trackingId,
    required DateTime day,
  });

  /// Reverses [markTaken]: removes [day] from `user_integratori.took_dates` for
  /// the record identified by [trackingId]. The "Preso oggi" CTA must be
  /// reversible, so this is a no-op-safe undo rather than a permanent action.
  Future<void> unmarkTaken({
    required String trackingId,
    required String kitId,
    required DateTime day,
  });
}
