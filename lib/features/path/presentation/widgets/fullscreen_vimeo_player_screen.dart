import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/theme/app_spacing.dart';
import 'vimeo_player_controller.dart';

/// Pushes a full-screen route playing [embedUrl] via Vimeo, with a back
/// button always visible over the player (unlike the JS `requestFullscreen`
/// call inside the embed, which some WebView engines — notably iOS'
/// WKWebView — silently ignore, leaving the video stuck inline).
///
/// [onProgress], when provided, keeps firing while the fullscreen route is
/// open, so callers can track watch progress the same way they would for an
/// inline player.
Future<void> pushFullscreenVimeoPlayer(
  BuildContext context, {
  required Uri embedUrl,
  VimeoProgressCallback? onProgress,
}) {
  return Navigator.of(context).push(
    PageRouteBuilder(
      opaque: true,
      barrierColor: Colors.black,
      pageBuilder: (_, _, _) => FullscreenVimeoPlayerScreen(
        embedUrl: embedUrl,
        onProgress: onProgress,
      ),
    ),
  );
}

/// Full-screen Vimeo player: the WebView fills the screen (immersive system
/// UI, free orientation so a landscape/portrait video can rotate with the
/// device) with a floating back button always on top of the player, even
/// while it's playing.
class FullscreenVimeoPlayerScreen extends StatefulWidget {
  const FullscreenVimeoPlayerScreen({
    super.key,
    required this.embedUrl,
    this.onProgress,
  });

  final Uri embedUrl;
  final VimeoProgressCallback? onProgress;

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
      onProgress: widget.onProgress,
    );
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
            Positioned(
              top: AppSpacing.spaceSm,
              left: AppSpacing.spaceSm,
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
