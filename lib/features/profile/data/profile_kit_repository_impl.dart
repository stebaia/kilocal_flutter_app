import 'package:dio/dio.dart';

import '../../../core/config/env.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/graphql_client.dart';
import '../domain/entities/profile_kit.dart';
import '../domain/profile_kit_repository.dart';
import 'dto/profile_kit_dto.dart';

/// GraphQL-backed implementation of [ProfileKitRepository].
///
/// Loads the kit (plan copy + image + CTA) and its supplement products from
/// `product_kits`, flattening the products across all phases. See
/// [[integrazione-schema]].
class ProfileKitRepositoryImpl implements ProfileKitRepository {
  ProfileKitRepositoryImpl({required GraphqlClient graphqlClient})
    : _graphqlClient = graphqlClient;

  final GraphqlClient _graphqlClient;

  static const _kitQuery = r'''
query ProfileKit($kitId: ID!, $lang: String!) {
  product_kits_by_id(id: $kitId) {
    id
    price
    asset { id default_asset { id filename_download } }
    cta {
      translations(filter: { languages_code: { code: { _eq: $lang } } }) {
        languages_code { code }
        label
        url
      }
    }
    translations(filter: { languages_code: { code: { _eq: $lang } } }) {
      languages_code { code }
      tipo_kit
      description
    }
    phases(sort: ["sort"]) {
      sort
      products_with_duration {
        kit_products_duration_id {
          product {
            id
            title
            price
            show_in_shop
            asset { id default_asset { id filename_download } }
            cta {
              translations(
                filter: { languages_code: { code: { _eq: $lang } } }
              ) {
                languages_code { code }
                label
                url
              }
            }
            translations(
              filter: { languages_code: { code: { _eq: $lang } } }
            ) {
              languages_code { code }
              title
              description
            }
          }
        }
      }
    }
  }
}
''';

  @override
  Future<ProfileKit?> fetchKit({
    required String kitId,
    required String lang,
  }) async {
    try {
      final result = await _graphqlClient.query(
        _kitQuery,
        variables: {'kitId': kitId, 'lang': lang},
      );
      final raw =
          (result['data'] as Map<String, dynamic>?)?['product_kits_by_id']
              as Map<String, dynamic>?;
      if (raw == null) return null;

      return _mapKit(ProfileKitDto.fromJson(raw));
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  ProfileKit _mapKit(ProfileKitDto dto) {
    final translation = dto.translations.firstOrNull;

    // Flatten every product across all phases, in phase order, keeping the
    // first occurrence of each product id (a product may repeat across phases).
    final products = <ProfileKitProduct>[];
    final seen = <String>{};
    for (final phase in dto.phases) {
      for (final junction in phase.productsWithDuration) {
        final product = junction.durationEntry?.product;
        if (product == null) continue;
        // Only surface products that are meant to appear in the shop.
        if (!product.showInShop) continue;
        if (!seen.add(product.id)) continue;
        products.add(_mapProduct(product));
      }
    }

    return ProfileKit(
      id: dto.id,
      typeLabel: translation?.tipoKit,
      planTitle: translation?.tipoKit,
      description: translation?.description,
      imageUrl: _imageUrl(dto.asset),
      price: dto.price,
      cta: _mapCta(dto.cta),
      products: products,
    );
  }

  ProfileKitProduct _mapProduct(KitProductDto dto) {
    final translation = dto.translations.firstOrNull;
    return ProfileKitProduct(
      id: dto.id,
      title: translation?.title ?? dto.title ?? '',
      description: translation?.description,
      imageUrl: _imageUrl(dto.asset),
      price: dto.price,
      cta: _mapCta(dto.cta),
    );
  }

  /// Builds `{baseUrl}/assets/<fileId>/<filename>` from an `assets` entity, or
  /// `null` when the entity has no underlying file (see [[cms-asset-url-pattern]]).
  String? _imageUrl(KitAssetDto? asset) {
    final file = asset?.defaultAsset;
    if (file?.id == null) return null;
    return '${Env.baseUrl}/assets/${file!.id}/${file.filenameDownload ?? ''}';
  }

  ProfileKitCta? _mapCta(KitLinkDto? link) {
    final translation = link?.translations.firstOrNull;
    if (translation == null) return null;
    final label = translation.label;
    if (label == null || label.isEmpty) return null;
    return ProfileKitCta(label: label, url: translation.url);
  }
}
