import '../exports.dart';

void main() {
  testWidgets('detalle: abre el evento tocado y ofrece reservar', (
    WidgetTester tester,
  ) async {
    if (skipWithoutSession()) return;

    await ensureSignedIn();
    await launchAt(tester, EventsPage.routePath);

    // Se afirma el catálogo antes de omitir: un fallo no debe pasar por vacío.
    expect(find.byType(EventsPage), findsOneWidget);
    await waitForData(tester);

    if (find.byType(EventCard).evaluate().isEmpty) {
      markTestSkipped('El catálogo cargó pero está vacío: nada que abrir');
      return;
    }

    // El título de la tarjeta es lo que debe reaparecer en el detalle.
    final Finder firstCard = find.byType(EventCard).first;
    final String title = tester
        .widget<Text>(
          find
              .descendant(of: firstCard, matching: find.byType(Text))
              .first,
        )
        .data!;

    await tester.tap(firstCard);
    await pumpUntil(
      tester,
      () => find.byType(EventDetailPage).evaluate().isNotEmpty,
      reason: 'que se abra el detalle del evento',
    );
    // El evento y la disponibilidad son dos consultas que llegan después.
    await waitForData(tester);

    expect(find.text(title), findsOneWidget);
    expect(find.text('Descripción'), findsOneWidget);

    final bool canReserve =
        find.widgetWithText(UiButton, 'Reservar').evaluate().isNotEmpty;
    final bool soldOut =
        find.widgetWithText(UiButton, 'Agotado').evaluate().isNotEmpty;
    expect(
      canReserve || soldOut,
      isTrue,
      reason: 'el detalle siempre resuelve a reservar o a agotado',
    );

    if (canReserve) {
      await tester.tap(find.widgetWithText(UiButton, 'Reservar'));
      await pumpUntil(
        tester,
        () => find.byType(ReservePage).evaluate().isNotEmpty,
        reason: 'que se abra el formulario de reserva',
      );
    }
  });
}
