import 'dart:async';

import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/features/payments/domain/entities/checkout_result.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Abre Stripe Checkout dentro de la app y devuelve un [CheckoutResult].
///
/// Intercepta la navegación al `return_url` (`.../stripe-return?status=...`)
/// ANTES de que cargue, así esa página nunca se muestra y cerramos el WebView
/// con `Navigator.pop`. Se usa Navigator imperativo (no GoRouter) a propósito:
/// es un flujo modal que devuelve un valor tipado al caller.
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
              final CheckoutResult result = CheckoutResult.fromStatus(
                Uri.parse(request.url).queryParameters['status'],
              );
              if (mounted) Navigator.of(context).pop(result);
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
          onPressed: () => Navigator.of(context).pop(CheckoutResult.cancel),
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
