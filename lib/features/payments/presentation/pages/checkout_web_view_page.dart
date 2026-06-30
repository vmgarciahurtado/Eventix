import 'dart:async';

import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Abre Stripe Checkout dentro de la app y devuelve el resultado.
///
/// Intercepta la navegación al `return_url` (`.../stripe-return?status=...`)
/// ANTES de que cargue, así esa página nunca se muestra y cerramos el WebView
/// devolviendo `'success'` o `'cancel'` vía `Navigator.pop`.
class CheckoutWebViewPage extends StatefulWidget {
  const CheckoutWebViewPage({required this.url, super.key});

  final String url;

  @override
  State<CheckoutWebViewPage> createState() => _CheckoutWebViewPageState();
}

class _CheckoutWebViewPageState extends State<CheckoutWebViewPage> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final WebViewController controller = WebViewController();
    unawaited(controller.setJavaScriptMode(JavaScriptMode.unrestricted));
    unawaited(
      controller.setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.contains('/stripe-return')) {
              final String status =
                  Uri.parse(request.url).queryParameters['status'] ?? 'success';
              if (mounted) Navigator.of(context).pop(status);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      ),
    );
    unawaited(controller.loadRequest(Uri.parse(widget.url)));
    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pago seguro'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop('cancel'),
        ),
      ),
      body: Stack(
        children: <Widget>[
          WebViewWidget(controller: _controller),
          if (_loading) const Center(child: UiLoader()),
        ],
      ),
    );
  }
}
