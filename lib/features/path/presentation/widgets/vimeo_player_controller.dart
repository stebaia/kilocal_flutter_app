import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

/// Builds the [WebViewController] used to play a Vimeo embed, with fullscreen
/// enabled.
///
/// Vimeo's fullscreen button only works when the platform view allows it:
/// Android needs an `onShowCustomView` handler (without one the player's own
/// fullscreen request is silently dropped), and WKWebView needs inline playback
/// turned on so the video renders in place until the user asks for fullscreen.
WebViewController buildVimeoController(Uri url) {
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
    ..loadRequest(url);

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
