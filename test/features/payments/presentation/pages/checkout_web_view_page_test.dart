import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/features/payments/domain/enums/checkout_result.dart';
import 'package:eventix/features/payments/presentation/pages/checkout_web_view_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import '../../../../helpers/fake_webview.dart';
import '../../../../helpers/pump_app.dart';

/// Decide si un pago cuenta como hecho. Se prueba con un `WebViewPlatform`
/// falso: importa cómo reacciona la página, no pintar la web de la pasarela.
void main() {
  const String marker = '/stripe-return';
  const String returnUrl = 'https://proyecto.supabase.test/functions/v1$marker';

  late FakeWebViewPlatform platform;
  late List<CheckoutResult?> results;

  setUp(() {
    platform = FakeWebViewPlatform.install();
    results = <CheckoutResult?>[];
  });

  /// Empuja el checkout sobre otra pantalla y guarda en [results] el valor
  /// con el que vuelve.
  Future<void> pushCheckout(WidgetTester tester) async {
    await pumpComponent(
      tester,
      Builder(
        builder: (BuildContext context) => TextButton(
          onPressed: () async {
            results.add(
              await Navigator.of(context).push<CheckoutResult>(
                MaterialPageRoute<CheckoutResult>(
                  builder: (_) => const CheckoutWebViewPage(
                    url: 'https://checkout.stripe.test/cs_test_123',
                    returnUrlMarker: marker,
                  ),
                ),
              ),
            );
          },
          child: const Text('abrir'),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  FakeWebViewController controller() => platform.controller!;

  /// Avanza el reloj a mano: el `UiLoader` es un Lottie en bucle y
  /// `pumpAndSettle` nunca vuelve.
  Future<void> advance(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('carga la URL del checkout que le dieron', (
    WidgetTester tester,
  ) async {
    await pushCheckout(tester);

    expect(
      controller().loadedUrl.toString(),
      'https://checkout.stripe.test/cs_test_123',
    );
    expect(find.text('Pago seguro'), findsOneWidget);
  });

  testWidgets('muestra el loader hasta que la web termina de cargar', (
    WidgetTester tester,
  ) async {
    await pushCheckout(tester);
    expect(find.byType(UiLoader), findsOneWidget);

    controller().finishLoading('https://checkout.stripe.test/cs_test_123');
    await advance(tester);

    expect(find.byType(UiLoader), findsNothing);
    expect(find.byKey(const Key('fake-webview')), findsOneWidget);
  });

  testWidgets('deja navegar dentro de la pasarela', (
    WidgetTester tester,
  ) async {
    await pushCheckout(tester);

    final NavigationDecision decision = await controller().navigateTo(
      'https://checkout.stripe.test/cs_test_123/pay',
    );
    await advance(tester);

    expect(decision, NavigationDecision.navigate);
    expect(find.byType(CheckoutWebViewPage), findsOneWidget);
    expect(results, isEmpty);
  });

  testWidgets('volver con status=success cierra con éxito', (
    WidgetTester tester,
  ) async {
    await pushCheckout(tester);

    final NavigationDecision decision = await controller().navigateTo(
      '$returnUrl?status=success',
    );
    await advance(tester);

    // La URL de retorno es una señal, no una página que el usuario deba ver.
    expect(decision, NavigationDecision.prevent);
    expect(results, <CheckoutResult>[CheckoutResult.success]);
  });

  testWidgets('volver con status=cancel cierra como cancelado', (
    WidgetTester tester,
  ) async {
    await pushCheckout(tester);

    await controller().navigateTo('$returnUrl?status=cancel');
    await advance(tester);

    expect(results, <CheckoutResult>[CheckoutResult.cancel]);
  });

  testWidgets('volver sin status no se toma como pago hecho', (
    WidgetTester tester,
  ) async {
    await pushCheckout(tester);

    await controller().navigateTo(returnUrl);
    await advance(tester);

    expect(results, <CheckoutResult>[CheckoutResult.cancel]);
  });

  testWidgets('cerrar con la X cuenta como cancelar', (
    WidgetTester tester,
  ) async {
    await pushCheckout(tester);

    await tester.tap(find.byIcon(Icons.close));
    await advance(tester);

    // Nunca se asume un pago por cerrar la pantalla.
    expect(results, <CheckoutResult>[CheckoutResult.cancel]);
  });
}
