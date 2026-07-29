import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/theme/app_spacing.dart';
import 'vimeo_player_controller.dart';

/// Pushes a full-screen route playing [embedUrl] via Vimeo, with a back
/// button always visible over the player. The device/app orientation is
/// never touched — a landscape video is rotated in place with CSS inside the
/// WebView so it fills the portrait screen edge-to-edge (see
/// [buildVimeoController]'s `rotateForLandscape`); a vertical video plays
/// upright as-is.
///
/// [onProgress], when provided, keeps firing while the fullscreen route is
/// open, so callers can track watch progress the same way they would for an
/// inline player. [onEnded] fires once, when the video finishes; the route
/// pops itself at that point regardless, so callers only need it to react to
/// completion (e.g. unlocking the "mark as done" button).
Future<void> pushFullscreenVimeoPlayer(
  BuildContext context, {
  required Uri embedUrl,
  bool isLandscape = true,
  VimeoProgressCallback? onProgress,
  VoidCallback? onEnded,
}) {
  // rootNavigator: true — the step/material screens live inside GoRouter's
  // StatefulShellRoute (the bottom-nav shell), whose own nested Navigator sits
  // below the AppScaffold's bottomNavigationBar. Pushing on that nested
  // Navigator stacks the player behind the bottom bar instead of covering the
  // whole screen; pushing on the root Navigator escapes the shell entirely.
  return Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder(
      opaque: true,
      barrierColor: Colors.black,
      pageBuilder: (_, _, _) => FullscreenVimeoPlayerScreen(
        embedUrl: embedUrl,
        isLandscape: isLandscape,
        onProgress: onProgress,
        onEnded: onEnded,
      ),
    ),
  );
}

/// Full-screen Vimeo player: the WebView fills the screen (immersive system
/// UI) with a floating back button always on top of the player, even while
/// it's playing. Closes itself automatically once the video finishes.
///
/// The app/device orientation is never changed — landscape videos are
/// rotated with CSS *inside* the WebView instead (see [buildVimeoController]),
/// since a Flutter `Transform` on the WebView platform view itself renders
/// black on both engines.
class FullscreenVimeoPlayerScreen extends StatefulWidget {
  const FullscreenVimeoPlayerScreen({
    super.key,
    required this.embedUrl,
    this.isLandscape = true,
    this.onProgress,
    this.onEnded,
  });

  final Uri embedUrl;

  /// Whether the source video is wider than it is tall; when true, the
  /// player rotates itself via CSS to fill the portrait screen.
  final bool isLandscape;

  final VimeoProgressCallback? onProgress;
  final VoidCallback? onEnded;

  @override
  State<FullscreenVimeoPlayerScreen> createState() =>
      _FullscreenVimeoPlayerScreenState();
}

class _FullscreenVimeoPlayerScreenState
    extends State<FullscreenVimeoPlayerScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = buildVimeoController(
      widget.embedUrl,
      rotateForLandscape: widget.isLandscape,
      onProgress: widget.onProgress,
      onEnded: _handleEnded,
    );
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _handleEnded() {
    widget.onEnded?.call();
    if (mounted) Navigator.maybePop(context);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            WebViewWidget(controller: _controller),
            // The CSS rotate(90deg) that turns a landscape video sideways (see
            // buildVimeoController) also carries its top-left corner to the
            // screen's top-right; the back button follows so it still reads
            // as "the player's own top-left" once rotated.
            Positioned(
              top: AppSpacing.spaceSm,
              left: widget.isLandscape ? null : AppSpacing.spaceSm,
              right: widget.isLandscape ? AppSpacing.spaceSm : null,
              child: SafeArea(
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
