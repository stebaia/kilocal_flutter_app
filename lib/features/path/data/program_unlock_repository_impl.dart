import '../../../core/network/api_exception.dart';
import '../../../core/network/graphql_client.dart';
import '../domain/entities/barcode_product.dart';
import '../domain/program_unlock_repository.dart';

/// GraphQL-backed implementation of [ProgramUnlockRepository].
///
/// Reads the barcode-check catalogue from the Directus `products` collection.
/// Barcodes live in a JSON field shaped `[{ "codice": "A947328593" }]`, both on
/// the product and on each `variants` row. See `wiki/integrazione.md`.
class ProgramUnlockRepositoryImpl implements ProgramUnlockRepository {
  ProgramUnlockRepositoryImpl({required GraphqlClient graphqlClient})
    : _graphqlClient = graphqlClient;

  final GraphqlClient _graphqlClient;

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
        (result['data'] as Map<String, dynamic>?)?['products'] as List<dynamic>?;
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
    // STUB — the backend contract for lifting `active_restricted_access` after a
    // valid barcode match is not yet defined. See
    // [[restricted-access-path-gating]] / wiki/integrazione.md ("OPEN (BE)").
    // Once the backend confirms the field/mutation, wire it here.
    throw const ApiException(
      type: ApiErrorType.unknown,
      statusCode: 501,
      message: 'Program unlock persistence not implemented (pending backend).',
    );
  }
}
