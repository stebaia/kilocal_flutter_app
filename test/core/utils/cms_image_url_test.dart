import 'package:flutter_test/flutter_test.dart';
import 'package:kilocal_flutter_app/core/config/env.dart';
import 'package:kilocal_flutter_app/core/utils/cms_image_url.dart';

void main() {
  group('cmsImageUrl', () {
    test('returns null for a null or empty id', () {
      expect(cmsImageUrl(null, size: CmsImageSize.card), isNull);
      expect(cmsImageUrl('', size: CmsImageSize.card), isNull);
    });

    test('asks the CMS to resize instead of serving the original', () {
      final url = cmsImageUrl('abc', size: CmsImageSize.card)!;
      final query = Uri.parse(url).queryParameters;

      expect(url, startsWith('${Env.baseUrl}/assets/abc?'));
      expect(query['width'], '400');
      expect(query['format'], 'webp');
      expect(query['quality'], '80');
    });

    test('never upscales an original that is already small', () {
      // `fit=cover` would enlarge a small image, making the response heavier
      // than the original it replaced.
      final query = Uri.parse(
        cmsImageUrl('abc', size: CmsImageSize.hero)!,
      ).queryParameters;

      expect(query['fit'], 'inside');
      expect(query['withoutEnlargement'], 'true');
    });

    test('scales the requested width by the device pixel ratio', () {
      final query = Uri.parse(
        cmsImageUrl('abc', size: CmsImageSize.card, pixelRatio: 3)!,
      ).queryParameters;

      expect(query['width'], '1200');
    });

    test('caps the width so a dense screen cannot request a huge render', () {
      final query = Uri.parse(
        cmsImageUrl('abc', size: CmsImageSize.full, pixelRatio: 4)!,
      ).queryParameters;

      expect(query['width'], '1600');
    });

    test('appends the filename when there is one, encoded', () {
      final url = cmsImageUrl(
        'abc',
        size: CmsImageSize.card,
        filename: 'Obiettivo della settimana.png',
      )!;

      expect(
        url,
        startsWith(
          '${Env.baseUrl}/assets/abc/Obiettivo%20della%20settimana.png?',
        ),
      );
    });

    test(
      'omits the filename segment when absent, leaving no dangling slash',
      () {
        expect(
          cmsImageUrl('abc', size: CmsImageSize.card, filename: ''),
          startsWith('${Env.baseUrl}/assets/abc?'),
        );
      },
    );

    test('requests a smaller render for a thumb than for a hero', () {
      final thumb = int.parse(
        Uri.parse(
          cmsImageUrl('a', size: CmsImageSize.thumb)!,
        ).queryParameters['width']!,
      );
      final hero = int.parse(
        Uri.parse(
          cmsImageUrl('a', size: CmsImageSize.hero)!,
        ).queryParameters['width']!,
      );

      expect(thumb, lessThan(hero));
    });
  });

  group('cmsFileUrl', () {
    test('returns null for a null or empty id', () {
      expect(cmsFileUrl(null), isNull);
      expect(cmsFileUrl(''), isNull);
    });

    test('carries no image transformation, so PDFs stay downloadable', () {
      final url = cmsFileUrl('abc', filename: 'Guida.pdf')!;

      expect(url, '${Env.baseUrl}/assets/abc/Guida.pdf');
      expect(Uri.parse(url).queryParameters, isEmpty);
    });

    test('encodes spaces so url_launcher can parse the url', () {
      expect(
        cmsFileUrl('abc', filename: 'Obiettivo della settimana.pdf'),
        '${Env.baseUrl}/assets/abc/Obiettivo%20della%20settimana.pdf',
      );
    });
  });
}
