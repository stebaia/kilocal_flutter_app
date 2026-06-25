import 'package:dio/dio.dart';

/// Lightweight metadata for a Vimeo video fetched via the public oEmbed API.
class VimeoOembed {
  const VimeoOembed({this.thumbnailUrl, this.duration});

  /// Poster image for the video, upscaled to a screen-friendly width.
  final String? thumbnailUrl;

  /// Video length, used to render the duration overlay.
  final Duration? duration;
}

/// Fetches public Vimeo metadata (thumbnail + duration) via oEmbed.
///
/// oEmbed is a public, unauthenticated endpoint on `vimeo.com`, so it uses its
/// own bare [Dio] instance — it must not go through the app's auth interceptor
/// or base URL.
class VimeoOembedService {
  VimeoOembedService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static const String _endpoint = 'https://vimeo.com/api/oembed.json';

  /// Returns metadata for [videoUrl], or `null` when the video is private,
  /// the URL is malformed, or the network call fails. Never throws.
  Future<VimeoOembed?> fetch(String videoUrl) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _endpoint,
        queryParameters: {'url': videoUrl},
      );
      final data = response.data;
      if (data == null) return null;

      final seconds = data['duration'];
      return VimeoOembed(
        thumbnailUrl: _upscale(data['thumbnail_url'] as String?),
        duration: seconds is int ? Duration(seconds: seconds) : null,
      );
    } on DioException {
      return null;
    }
  }

  /// Vimeo returns a small poster (`..._295x166`). Bump the dimensions so the
  /// thumbnail is crisp on the full-width media header.
  String? _upscale(String? url) {
    if (url == null) return null;
    return url.replaceAll(RegExp(r'_\d+x\d+'), '_960x540');
  }
}
