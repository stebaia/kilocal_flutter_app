import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

/// Fires with the fraction (0.0-1.0) of the video watched so far, on every
/// Vimeo `timeupdate` event.
typedef VimeoProgressCallback = void Function(double fraction);

/// JS channel name the host HTML page posts Vimeo player events to.
const _kVimeoChannelName = 'VimeoEvents';

/// Payload posted on the channel when the video reaches its end, in place of
/// a 0.0-1.0 progress fraction.
const _kEndedMessage = 'ended';

/// Builds the [WebViewController] used to play a Vimeo embed, with fullscreen
/// enabled and playback-progress reporting via the official Vimeo Player API.
///
/// The player is embedded inside a real host HTML page (loaded with
/// [WebViewController.loadHtmlString]) rather than navigating the WebView
/// directly to the `player.vimeo.com` URL: the Player API communicates with
/// its embedding page over `postMessage`, which only exists when there is an
/// actual parent document hosting the `<iframe>`. Loading the player URL
/// directly, with no such parent, gives no supported way to observe playback
/// — this host page is what makes `onProgress` possible.
WebViewController buildVimeoController(
  Uri url, {
  bool rotateForLandscape = false,
  VimeoProgressCallback? onProgress,
  VoidCallback? onEnded,
}) {
  final params = switch (WebViewPlatform.instance) {
    WebKitWebViewPlatform() => WebKitWebViewControllerCreationParams(
      allowsInlineMediaPlayback: true,
      mediaTypesRequiringUserAction: const {},
    ),
    _ => const PlatformWebViewControllerCreationParams(),
  };

  final controller = WebViewController.fromPlatformCreationParams(params)
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(const Color(0x00000000))
    ..addJavaScriptChannel(
      _kVimeoChannelName,
      onMessageReceived: (message) {
        if (message.message == _kEndedMessage) {
          onEnded?.call();
          return;
        }
        final fraction = double.tryParse(message.message);
        if (fraction != null) onProgress?.call(fraction);
      },
    )
    ..loadHtmlString(
      _hostHtml(url, rotate: rotateForLandscape),
      baseUrl: 'https://player.vimeo.com',
    );

  final platform = controller.platform;
  if (platform is AndroidWebViewController) {
    // Hands the player's fullscreen request to the platform, which presents the
    // video over the whole activity; the callbacks are no-ops because we have
    // nothing of our own to hide.
    platform.setCustomWidgetCallbacks(
      onShowCustomWidget: (_, _) {},
      onHideCustomWidget: () {},
    );
    AndroidWebViewController.enableDebugging(false);
    platform.setMediaPlaybackRequiresUserGesture(false);
  }

  return controller;
}

/// Host page embedding the Vimeo player via the official `player.js` SDK
/// (Vimeo Player API), so playback events are available over `postMessage`
/// exactly as Vimeo's own documentation describes for a page that owns the
/// `<iframe>`. The WebView itself already fills a dedicated full-screen native
/// route (see [FullscreenVimeoPlayerScreen]), so this page does not also call
/// the player's own `requestFullscreen()` — doing so on top of an
/// already-full-screen WebView was unreliable across engines and could eat
/// the tap that started playback, leaving the video paused. Reports watch
/// progress and the end-of-playback event back to Flutter via
/// [_kVimeoChannelName].
///
/// When [rotate] is true (a landscape video shown on a portrait screen), the
/// `<iframe>` is rotated 90° with plain CSS, sized to the screen's *rotated*
/// dimensions (`100vh` wide, `100vw` tall) before the rotation is applied —
/// this is rendering done entirely inside the WebView's own browser engine,
/// not a Flutter `Transform` on the platform view, which is what makes it
/// safe: Flutter transforms on an embedded WebView/WKWebView don't compose
/// correctly with the platform's own compositor and can leave the video
/// black, but the WebView's internal CSS engine handles a rotated iframe the
/// same way any web page would.
String _hostHtml(Uri embedUrl, {required bool rotate}) {
  final src = embedUrl.toString();
  final iframeStyle = rotate
      ? '''
    iframe {
      position: absolute;
      top: 50%;
      left: 50%;
      width: 100vh;
      height: 100vw;
      border: 0;
      transform: translate(-50%, -50%) rotate(90deg);
      transform-origin: center center;
    }
'''
      : '''
    iframe { position: absolute; top: 0; left: 0; width: 100%; height: 100%; border: 0; }
''';

  return '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
  <style>
    html, body { margin: 0; padding: 0; background: #000; height: 100%; overflow: hidden; }
$iframeStyle
  </style>
</head>
<body>
  <iframe id="vimeoPlayer" src="$src" allow="autoplay; fullscreen; picture-in-picture" allowfullscreen></iframe>
  <script src="https://player.vimeo.com/api/player.js"></script>
  <script>
    var iframe = document.getElementById('vimeoPlayer');
    var player = new Vimeo.Player(iframe);

    player.on('timeupdate', function(data) {
      if (data && data.duration) {
        $_kVimeoChannelName.postMessage(String(data.seconds / data.duration));
      }
    });

    player.on('ended', function() {
      $_kVimeoChannelName.postMessage('$_kEndedMessage');
    });
  </script>
</body>
</html>
''';
}
