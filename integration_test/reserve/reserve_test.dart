import '../exports.dart';

/// Si el evento es gratuito completa la reserva; si es pago, verifica el
/// diálogo de confirmación y cancela. El pago real va en el video.
void main() {
  testWidgets('reserva: cantidad, total y confirmación antes de cobrar', (
    WidgetTester tester,
  ) async {
    if (skipWithoutSession()) return;

    await ensureSignedIn();
    await launchAt(tester, EventsPage.routePath);

    // Se afirma el catálogo antes de omitir: un fallo no debe pasar por vacío.
    expect(find.byType(EventsPage), findsOneWidget);
    await waitForData(tester);

    if (find.byType(EventCard).evaluate().isEmpty) {
      markTestSkipped('El catálogo cargó pero está vacío: nada que reservar');
      return;
    }

    await tester.tap(find.byType(EventCard).first);
    await pumpUntil(
      tester,
      () => find.byType(EventDetailPage).evaluate().isNotEmpty,
      reason: 'que se abra el detalle del evento',
    );
    // La disponibilidad decide si el botón dice "Reservar" o "Agotado".
    await waitForData(tester);

    if (find.widgetWithText(UiButton, 'Reservar').evaluate().isEmpty) {
      markTestSkipped('El primer evento está agotado');
      return;
    }
    await tester.tap(find.widgetWithText(UiButton, 'Reservar'));
    await pumpUntil(
      tester,
      () => find.byType(ReservePage).evaluate().isNotEmpty,
      reason: 'que se abra el formulario de reserva',
    );
    // El tope de cantidad sale de los cupos libres: hay que esperarlos.
    await waitForData(tester);

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
    await pumpUntil(
      tester,
      () => find.byType(ReservationConfirmedPage).evaluate().isNotEmpty,
      reason: 'que la reserva gratuita quede confirmada',
    );

    expect(
      find.widgetWithText(UiButton, 'Ver mis reservas'),
      findsOneWidget,
    );
  });
}
