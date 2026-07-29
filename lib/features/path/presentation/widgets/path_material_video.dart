import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/vimeo_oembed_service.dart';
import '../../../../app/di.dart';
import 'fullscreen_vimeo_player_screen.dart';

/// Full-bleed video header for a material detail, mirroring the path-step video
/// layout: a custom poster (Vimeo oEmbed thumbnail + play button + duration)
/// with a floating back button over the media. Tapping play opens the video
/// full-screen (see [pushFullscreenVimeoPlayer]) rather than swapping in an
/// inline WebView — the JS `requestFullscreen` call some embeds rely on isn't
/// reliable across WebView engines, so full-screen playback is driven natively
/// instead.
///
/// Give it a stable [key] (the material id) so unrelated rebuilds don't reset
/// the poster fetch.
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
  /// Videos and their Vimeo posters are 16:9; a taller box would crop the sides
  /// of the poster away (the CMS covers carry titles near the edges).
  static const double _mediaAspectRatio = 16 / 9;

  /// Height for non-video media, which has no intrinsic ratio to honour.
  static const double _mediaHeight = 417;

  VimeoOembed? _oembed;

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
    // fullscreen=0 hides Vimeo's own fullscreen button: the player already
    // plays inside a Flutter-managed full-screen route (see
    // [FullscreenVimeoPlayerScreen]), so Vimeo's own requestFullscreen()
    // would have nothing left to do.
    final autoplayUrl = Uri.parse(embedUrl).replace(
      queryParameters: {
        ...Uri.parse(embedUrl).queryParameters,
        'autoplay': '1',
        'fullscreen': '0',
      },
    );

    pushFullscreenVimeoPlayer(
      context,
      embedUrl: autoplayUrl,
      isLandscape: _oembed?.isLandscape ?? true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final stack = ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Stack(
        fit: StackFit.expand,
        children: [_buildSurface(), const _BackButtonOverlay()],
      ),
    );

    // Videos size themselves to the 16:9 poster/player; images keep the fixed
    // header height.
    return SizedBox(
      width: double.infinity,
      child: _isVideo
          ? AspectRatio(aspectRatio: _mediaAspectRatio, child: stack)
          : SizedBox(height: _mediaHeight, child: stack),
    );
  }

  Widget _buildSurface() {
    if (_isVideo) {
      return _VideoPoster(
        thumbnailUrl: _oembed?.thumbnailUrl ?? widget.posterUrl,
        duration: _oembed?.duration,
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
    required this.onPlay,
  });

  final String? thumbnailUrl;
  final Duration? duration;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPlay,
      child: SizedBox.expand(
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
