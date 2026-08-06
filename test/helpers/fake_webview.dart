import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

/// Implementación de prueba de `WebViewPlatform`, el camino que documenta el
/// propio paquete: en pruebas no hay motor de navegador que pinte nada.
class FakeWebViewPlatform extends WebViewPlatform {
  /// Instálala antes de montar la página y recupera el control desde la prueba.
  static FakeWebViewPlatform install() {
    final FakeWebViewPlatform platform = FakeWebViewPlatform();
    WebViewPlatform.instance = platform;
    return platform;
  }

  /// El último controlador creado: por ahí se simula la navegación.
  FakeWebViewController? controller;

  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) => controller = FakeWebViewController(params);

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) => FakeNavigationDelegate(params);

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) => FakeWebViewWidget(params);
}

class FakeWebViewController extends PlatformWebViewController {
  FakeWebViewController(PlatformWebViewControllerCreationParams params)
    : super.implementation(params);

  /// La URL que la página mandó cargar.
  Uri? loadedUrl;

  FakeNavigationDelegate? delegate;

  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) async {}

  @override
  Future<void> setPlatformNavigationDelegate(
    PlatformNavigationDelegate handler,
  ) async => delegate = handler as FakeNavigationDelegate;

  @override
  Future<void> loadRequest(LoadRequestParams params) async =>
      loadedUrl = params.uri;

  /// Simula que el navegador terminó de cargar la página.
  void finishLoading(String url) => delegate?.onPageFinished?.call(url);

  /// Simula que el navegador va a navegar a [url] y devuelve lo que se decidió.
  Future<NavigationDecision> navigateTo(String url) async {
    final NavigationRequestCallback decide = delegate!.onNavigationRequest!;
    return decide(NavigationRequest(url: url, isMainFrame: true));
  }
}

class FakeNavigationDelegate extends PlatformNavigationDelegate {
  FakeNavigationDelegate(PlatformNavigationDelegateCreationParams params)
    : super.implementation(params);

  NavigationRequestCallback? onNavigationRequest;
  PageEventCallback? onPageFinished;

  @override
  Future<void> setOnNavigationRequest(
    NavigationRequestCallback callback,
  ) async => onNavigationRequest = callback;

  @override
  Future<void> setOnPageFinished(PageEventCallback callback) async =>
      onPageFinished = callback;
}

class FakeWebViewWidget extends PlatformWebViewWidget {
  FakeWebViewWidget(PlatformWebViewWidgetCreationParams params)
    : super.implementation(params);

  @override
  Widget build(BuildContext context) =>
      const SizedBox.expand(key: Key('fake-webview'));
}
