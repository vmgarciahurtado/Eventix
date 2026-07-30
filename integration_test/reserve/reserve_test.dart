import '../exports.dart';

/// Hasta dónde llega esta prueba: si el evento es gratuito completa la reserva
/// de punta a punta. Si es pago, verifica el diálogo de confirmación y cancela.
///
/// No se automatiza un pago real: dispararía un cobro en Stripe en cada
/// ejecución y el checkout hospedado es una web de terceros, no una pantalla
/// nuestra. El tramo de pago se demuestra en el video de la entrega.
void main() {
  testWidgets('reserva: cantidad, total y confirmación antes de cobrar', (
    WidgetTester tester,
  ) async {
    if (skipWithoutSession()) return;

    await goTo(tester, EventsPage.routePath);
    await settle(tester, timeout: const Duration(seconds: 20));

    if (find.byType(EventCard).evaluate().isEmpty) {
      markTestSkipped('El catálogo real no tiene eventos que reservar');
      return;
    }

    await tester.tap(find.byType(EventCard).first);
    await settle(tester, timeout: const Duration(seconds: 20));

    if (find.widgetWithText(UiButton, 'Reservar').evaluate().isEmpty) {
      markTestSkipped('El primer evento está agotado');
      return;
    }
    await tester.tap(find.widgetWithText(UiButton, 'Reservar'));
    await settle(tester, timeout: const Duration(seconds: 20));

    expect(find.byType(ReservePage), findsOneWidget);
    expect(find.text('Cantidad de cupos'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);

    // Subir la cantidad tiene que recalcular el total en pantalla.
    final Finder plus = find.widgetWithIcon(IconButton, Icons.add);
    if (tester.widget<IconButton>(plus).onPressed != null) {
      await tester.tap(plus);
      await settle(tester, timeout: const Duration(seconds: 3));
      expect(find.text('2'), findsOneWidget);
      await tester.tap(find.widgetWithIcon(IconButton, Icons.remove));
      await settle(tester, timeout: const Duration(seconds: 3));
      expect(find.text('1'), findsOneWidget);
    }

    final bool isFree =
        find.widgetWithText(UiButton, 'Reservar gratis').evaluate().isNotEmpty;

    if (!isFree) {
      // Evento pago: se comprueba que nada se cobre sin confirmar, y se corta.
      await tester.tap(find.byType(UiButton).last);
      await settle(tester, timeout: const Duration(seconds: 3));
      expect(find.text('Pagar con Stripe'), findsOneWidget);

      await tester.tap(find.text('Cancelar'));
      await settle(tester, timeout: const Duration(seconds: 5));
      expect(find.byType(ReservePage), findsOneWidget);
      return;
    }

    // Evento gratuito: se completa la reserva de verdad.
    await tester.tap(find.widgetWithText(UiButton, 'Reservar gratis'));
    await settle(tester, timeout: const Duration(seconds: 3));
    expect(find.textContaining('gratuito'), findsOneWidget);

    await tester.tap(find.text('Confirmar'));
    await settle(tester, timeout: const Duration(seconds: 30));

    expect(find.byType(ReservationConfirmedPage), findsOneWidget);
    expect(
      find.widgetWithText(UiButton, 'Ver mis reservas'),
      findsOneWidget,
    );
  });
}
