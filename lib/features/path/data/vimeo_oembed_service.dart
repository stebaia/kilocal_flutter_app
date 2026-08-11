import 'package:dio/dio.dart';

/// Lightweight metadata for a Vimeo video fetched via the public v2 video API.
class VimeoOembed {
  const VimeoOembed({
    this.thumbnailUrl,
    this.duration,
    this.width,
    this.height,
  });

  /// Poster image for the video (`thumbnail_large`, a fixed 640px-wide still).
  final String? thumbnailUrl;

  /// Video length, used to render the duration overlay.
  final Duration? duration;

  /// Source width/height in pixels, used to tell landscape from portrait
  /// footage so the full-screen player can pick the matching orientation.
  final int? width;
  final int? height;

  /// Whether the video is wider than it is tall. Defaults to `true` (the
  /// common case) when dimensions are missing.
  bool get isLandscape => (width ?? 1) >= (height ?? 1);
}

/// Fetches public Vimeo metadata (thumbnail + duration) via the legacy `v2`
/// video endpoint, matching what the Kilocal web frontend already does for the
/// same problem (CMS video steps have no cover image — see
/// [[home-continue-path-image-gap]] / [[statistics-feature-status]]): extract
/// the numeric id from the video's `vimeo_url` and fetch
/// `https://vimeo.com/api/v2/video/{id}.json`, reading `thumbnail_large`.
class VimeoOembedService {
  VimeoOembedService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  /// Results per video url, kept for the process lifetime. The materials list
  /// resolves a poster per video on every load, and the same videos also appear
  /// in the detail screen — without this each visit would re-hit Vimeo.
  /// Misses are cached too (as null), so a private video is not retried on
  /// every rebuild.
  final Map<String, VimeoOembed?> _cache = {};

  static const String _endpointTemplate = 'https://vimeo.com/api/v2/video';

  /// Matches the numeric video id in a Vimeo url, e.g. `vimeo.com/1120185037`
  /// or `vimeo.com/1120185037?ts=0&share=copy` — both seen live in the CMS's
  /// `vimeo_url` field. The optional `video/` segment also covers player links
  /// (`player.vimeo.com/video/1120185037`), which the CMS accepts too and which
  /// would otherwise resolve to no poster at all.
  static final RegExp _idPattern = RegExp(r'vimeo\.com/(?:video/)?(\d+)');

  /// Metadata for every url in [videoUrls], keyed by url, fetched concurrently.
  /// Urls whose lookup fails are absent from the result.
  Future<Map<String, VimeoOembed>> fetchAll(Iterable<String> videoUrls) async {
    final urls = videoUrls.toSet();
    final results = await Future.wait(urls.map(fetch));

    final byUrl = <String, VimeoOembed>{};
    for (final (index, url) in urls.indexed) {
      final data = results[index];
      if (data != null) byUrl[url] = data;
    }
    return byUrl;
  }

  /// Returns metadata for [videoUrl], or `null` when the id can't be parsed,
  /// the video is private, or the network call fails. Never throws.
  Future<VimeoOembed?> fetch(String videoUrl) async {
    if (_cache.containsKey(videoUrl)) return _cache[videoUrl];

    final data = await _fetch(videoUrl);
    _cache[videoUrl] = data;
    return data;
  }

  Future<VimeoOembed?> _fetch(String videoUrl) async {
    final id = _idPattern.firstMatch(videoUrl)?.group(1);
    if (id == null) return null;

    try {
      final response = await _dio.get<List<dynamic>>(
        '$_endpointTemplate/$id.json',
      );
      final entry = response.data?.firstOrNull as Map<String, dynamic>?;
      if (entry == null) return null;

      final seconds = entry['duration'];
      return VimeoOembed(
        thumbnailUrl: entry['thumbnail_large'] as String?,
        duration: seconds is int ? Duration(seconds: seconds) : null,
        width: entry['width'] as int?,
        height: entry['height'] as int?,
      );
    } on DioException {
      return null;
    }
  }
}
