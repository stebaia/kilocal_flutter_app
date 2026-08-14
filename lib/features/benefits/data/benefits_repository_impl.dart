import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/graphql_client.dart';
import '../../../core/utils/cms_image_url.dart';
import '../domain/benefits_repository.dart';
import '../domain/entities/benefit.dart';
import 'dto/benefit_dto.dart';

/// GraphQL-backed implementation of [BenefitsRepository].
class BenefitsRepositoryImpl implements BenefitsRepository {
  BenefitsRepositoryImpl({required GraphqlClient graphqlClient})
    : _graphqlClient = graphqlClient;

  final GraphqlClient _graphqlClient;

  static const _partnersQuery = r'''
query GetPartners($lang: String!) {
  partners(sort: ["name"]) {
    id
    name
    coupon
    main_partner
    asset {
      id
      filename_download
    }
    logo {
      id
      filename_download
    }
    cta_brand {
      id
      translations(filter: { languages_code: { code: { _eq: $lang } } }) {
        url
        label
      }
    }
    translations(filter: { languages_code: { code: { _eq: $lang } } }) {
      description
      coupon_instructions
    }
  }
}
''';

  @override
  Future<List<Benefit>> fetchBenefits() async {
    try {
      final result = await _graphqlClient.query(
        _partnersQuery,
        variables: {'lang': _resolveLocale()},
      );

      final data = result['data'] as Map<String, dynamic>?;
      final rawPartners = data?['partners'] as List<dynamic>?;

      return rawPartners?.map((json) {
            final dto = BenefitDto.fromJson(json as Map<String, dynamic>);
            return _mapDto(dto);
          }).toList() ??
          const [];
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Benefit _mapDto(BenefitDto dto) {
    final translation = dto.translations.firstOrNull;
    final cta = dto.ctaBrand?.translations.firstOrNull;

    return Benefit(
      id: dto.id,
      name: dto.name ?? '',
      mainPartner: dto.mainPartner ?? false,
      coupon: dto.coupon,
      description: translation?.description,
      couponInstructions: translation?.couponInstructions,
      // The cover is rendered as a hero/detail image, the logo as a small list
      // tile — requesting one size for both would over-fetch the logo.
      imageUrl: _assetUrl(dto.asset, CmsImageSize.hero),
      logoUrl: _assetUrl(dto.logo, CmsImageSize.thumb),
      ctaUrl: cta?.url,
    );
  }

  String? _assetUrl(BenefitFileDto? file, CmsImageSize size) {
    if (file?.id == null || file?.filenameDownload == null) return null;
    return cmsImageUrl(file!.id, size: size, filename: file.filenameDownload);
  }

  String _resolveLocale() {
    // The CMS uses codes like "it-IT" / "en-US". Default to Italian for now.
    return 'it-IT';
  }
}
