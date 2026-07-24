import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

/// Fires with the fraction (0.0-1.0) of the video watched so far, on every
/// Vimeo `timeupdate` event.
typedef VimeoProgressCallback = void Function(double fraction);

/// JS channel name the host HTML page posts Vimeo player events to.
const _kVimeoChannelName = 'VimeoEvents';

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
  VimeoProgressCallback? onProgress,
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
        final fraction = double.tryParse(message.message);
        if (fraction != null) onProgress?.call(fraction);
      },
    )
    ..loadHtmlString(_hostHtml(url), baseUrl: 'https://player.vimeo.com');

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
/// `<iframe>`. Requests fullscreen automatically once playback starts (with
/// Vimeo's own player chrome, so the user can still shrink it back down from
/// there), and reports watch progress back to Flutter via
/// [_kVimeoChannelName].
String _hostHtml(Uri embedUrl) {
  final src = embedUrl.toString();
  return '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
  <style>
    html, body { margin: 0; padding: 0; background: #000; height: 100%; overflow: hidden; }
    iframe { position: absolute; top: 0; left: 0; width: 100%; height: 100%; border: 0; }
  </style>
</head>
<body>
  <iframe id="vimeoPlayer" src="$src" allow="autoplay; fullscreen; picture-in-picture" allowfullscreen></iframe>
  <script src="https://player.vimeo.com/api/player.js"></script>
  <script>
    var iframe = document.getElementById('vimeoPlayer');
    var player = new Vimeo.Player(iframe);
    var requestedFullscreen = false;

    player.on('play', function() {
      if (!requestedFullscreen) {
        requestedFullscreen = true;
        player.requestFullscreen().catch(function() {});
      }
    });

    player.on('timeupdate', function(data) {
      if (data && data.duration) {
        $_kVimeoChannelName.postMessage(String(data.seconds / data.duration));
      }
    });
  </script>
</body>
</html>
''';
}
