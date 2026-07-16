import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/vimeo_oembed_service.dart';
import '../../../../app/di.dart';
import 'vimeo_player_controller.dart';

/// Full-bleed video header for a material detail, mirroring the path-step video
/// layout: a custom poster (Vimeo oEmbed thumbnail + play button + duration)
/// that swaps to an autoplaying Vimeo WebView on tap, with a floating back
/// button over the media.
///
/// Give it a stable [key] (the material id) so the WebView survives unrelated
/// rebuilds.
class PathMaterialVideo extends StatefulWidget {
  const PathMaterialVideo({
    super.key,
    required this.embedUrl,
    required this.vimeoUrl,
    this.posterUrl,
  });

  final String? embedUrl;
  final String? vimeoUrl;
  final String? posterUrl;

  @override
  State<PathMaterialVideo> createState() => _PathMaterialVideoState();
}

class _PathMaterialVideoState extends State<PathMaterialVideo> {
  static const double _mediaHeight = 417;

  VimeoOembed? _oembed;
  WebViewController? _controller;

  bool get _isVideo => widget.embedUrl != null;

  @override
  void initState() {
    super.initState();
    if (_isVideo) _fetchOembed();
  }

  Future<void> _fetchOembed() async {
    final url = widget.vimeoUrl;
    if (url == null) return;
    final data = await getIt<VimeoOembedService>().fetch(url);
    if (mounted) setState(() => _oembed = data);
  }

  void _play() {
    final embedUrl = widget.embedUrl;
    if (embedUrl == null) return;
    final autoplayUrl = Uri.parse(embedUrl).replace(
      queryParameters: {
        ...Uri.parse(embedUrl).queryParameters,
        'autoplay': '1',
      },
    );

    setState(() {
      _controller = buildVimeoController(autoplayUrl);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _mediaHeight,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildSurface(),
            if (_controller == null) const _BackButtonOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildSurface() {
    final controller = _controller;
    if (controller != null) return WebViewWidget(controller: controller);

    if (_isVideo) {
      return _VideoPoster(
        thumbnailUrl: _oembed?.thumbnailUrl ?? widget.posterUrl,
        duration: _oembed?.duration,
        height: _mediaHeight,
        onPlay: _play,
      );
    }

    if (widget.posterUrl != null) {
      return Image.network(widget.posterUrl!, fit: BoxFit.cover);
    }

    return Container(
      color: AppColors.surface,
      child: const Center(
        child: Icon(Icons.image_not_supported, color: AppColors.textSecondary),
      ),
    );
  }
}

class _BackButtonOverlay extends StatelessWidget {
  const _BackButtonOverlay();

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.paddingOf(context).top;
    return Positioned(
      top: statusBarHeight + AppSpacing.spaceSm,
      left: AppSpacing.screenGutter,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.maybePop(context),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.chevron_left, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

/// Custom poster shown before playback: thumbnail, play button and duration.
class _VideoPoster extends StatelessWidget {
  const _VideoPoster({
    required this.thumbnailUrl,
    required this.duration,
    required this.height,
    required this.onPlay,
  });

  final String? thumbnailUrl;
  final Duration? duration;
  final double height;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPlay,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (thumbnailUrl != null)
              Image.network(
                thumbnailUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(color: Colors.black12),
              )
            else
              Container(color: Colors.black12),
            const DecoratedBox(
              decoration: BoxDecoration(color: Colors.black26),
            ),
            const Center(
              child: Icon(
                Icons.play_circle_fill,
                color: Colors.white,
                size: 64,
              ),
            ),
            if (duration != null)
              Positioned(
                right: AppSpacing.spaceMd,
                bottom: AppSpacing.spaceMd,
                child: _DurationBadge(duration: duration!),
              ),
          ],
        ),
      ),
    );
  }
}

class _DurationBadge extends StatelessWidget {
  const _DurationBadge({required this.duration});

  final Duration duration;

  String _format() {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spaceSm,
        vertical: AppSpacing.spaceXs,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        l10n.pathStepVideoDuration(_format()),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
