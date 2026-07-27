import 'dart:async';

import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/l10n/app_localizations.dart';
import 'package:eventix/features/payments/domain/enums/checkout_result.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Abre un checkout hospedado y devuelve un [CheckoutResult].
class CheckoutWebViewPage extends StatefulWidget {
  const CheckoutWebViewPage({
    required this.url,
    required this.returnUrlMarker,
    super.key,
  });

  final String url;

  /// Ver [CheckoutSession.returnUrlMarker]: marca el fin del flujo sin que
  /// esta página sepa qué pasarela lo atiende.
  final String returnUrlMarker;

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
            if (request.url.contains(widget.returnUrlMarker)) {
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
        title: Text(AppLocalizations.of(context).checkout_title),
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
