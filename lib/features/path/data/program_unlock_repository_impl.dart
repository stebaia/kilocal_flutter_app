import '../../../core/network/graphql_client.dart';
import '../../user/domain/user_repository.dart';
import '../domain/entities/barcode_product.dart';
import '../domain/program_unlock_repository.dart';

/// GraphQL-backed implementation of [ProgramUnlockRepository].
///
/// Reads the barcode-check catalogue from the Directus `products` collection.
/// Barcodes live in a JSON field shaped `[{ "codice": "A947328593" }]`, both on
/// the product and on each `variants` row. See `wiki/integrazione.md`.
class ProgramUnlockRepositoryImpl implements ProgramUnlockRepository {
  ProgramUnlockRepositoryImpl({
    required GraphqlClient graphqlClient,
    required UserRepository userRepository,
  }) : _graphqlClient = graphqlClient,
       _userRepository = userRepository;

  final GraphqlClient _graphqlClient;
  final UserRepository _userRepository;

  static const _barcodeProductsQuery = r'''
query BarcodeProducts {
  products(filter: { use_for_barcode_check: { _eq: true } }) {
    id
    title
    barcodes
    variants {
      barcodes
    }
  }
}
''';

  @override
  Future<List<BarcodeProduct>> fetchBarcodeProducts() async {
    final result = await _graphqlClient.query(_barcodeProductsQuery);
    final products =
        (result['data'] as Map<String, dynamic>?)?['products']
            as List<dynamic>?;
    if (products == null) return const [];

    return products
        .whereType<Map<String, dynamic>>()
        .map(_mapProduct)
        .where((p) => p.codes.isNotEmpty)
        .toList();
  }

  BarcodeProduct _mapProduct(Map<String, dynamic> json) {
    final codes = <String>{
      ..._codesFrom(json['barcodes']),
      for (final variant
          in (json['variants'] as List<dynamic>? ?? const [])
              .whereType<Map<String, dynamic>>())
        ..._codesFrom(variant['barcodes']),
    };
    return BarcodeProduct(
      id: '${json['id']}',
      title: (json['title'] as String?)?.trim() ?? '',
      codes: codes,
    );
  }

  /// Reads the `codice` values from a `barcodes` JSON field
  /// (`[{ "codice": "A947328593" }]`), normalised to upper case.
  Iterable<String> _codesFrom(dynamic barcodes) sync* {
    if (barcodes is! List) return;
    for (final entry in barcodes) {
      if (entry is Map && entry['codice'] is String) {
        final code = (entry['codice'] as String).trim().toUpperCase();
        if (code.isNotEmpty) yield code;
      }
    }
  }

  @override
  Future<void> unlockWithProduct(BarcodeProduct product) async {
    // Backend contract (confirmed 2026-07-09): the app lifts the restriction via
    // `PATCH /profile` with `{ has_kit_purchased: true, profile_status: 'active' }`.
    // A restricted user who unlocks with the purchase barcode has already done
    // `type_survey` (so they have a biotype) and the `sp-kilocal` questionnaire,
    // so the BE now allows the jump straight to `active` — no surveys are replayed.
    //
    // History: the `active_restricted_access` state machine previously rejected
    // `→ active` with `INVALID_PAYLOAD`, forcing a detour through `starter_kit`
    // (which replays the 17-question survey) or `initial_survey` (which reopens
    // the biotype quiz and 500s the CMS result template). The BE unblocked the
    // direct `→ active` transition on staging. See [[restricted-access-path-gating]].
    await _userRepository.updateProfile(<String, dynamic>{
      'has_kit_purchased': true,
      'profile_status': 'active',
    });
  }
}
