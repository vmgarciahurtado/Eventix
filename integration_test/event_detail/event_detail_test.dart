import '../exports.dart';

void main() {
  testWidgets('detalle: abre el evento tocado y ofrece reservar', (
    WidgetTester tester,
  ) async {
    if (skipWithoutSession()) return;

    await goTo(tester, EventsPage.routePath);
    await settle(tester, timeout: const Duration(seconds: 20));

    if (find.byType(EventCard).evaluate().isEmpty) {
      markTestSkipped('El catálogo real no tiene eventos que abrir');
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
    await settle(tester, timeout: const Duration(seconds: 20));

    expect(find.byType(EventDetailPage), findsOneWidget);
    expect(find.text(title), findsOneWidget);
    expect(find.text('Descripción'), findsOneWidget);

    // La disponibilidad la calcula la BD: debe haber resuelto a un número o a
    // "Agotado", nunca quedarse en "consultando".
    expect(find.text('Consultando disponibilidad…'), findsNothing);

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
      await settle(tester, timeout: const Duration(seconds: 20));
      expect(find.byType(ReservePage), findsOneWidget);
    }
  });
}
