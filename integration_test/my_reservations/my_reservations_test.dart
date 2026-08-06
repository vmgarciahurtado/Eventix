import '../exports.dart';

void main() {
  testWidgets('mis reservas: lista lo del usuario en sesión y refresca', (
    WidgetTester tester,
  ) async {
    if (skipWithoutSession()) return;

    await ensureSignedIn();
    await launchAt(tester, EventsPage.routePath);
    expect(find.byType(EventsPage), findsOneWidget);
    await waitForData(tester);

    await tester.tap(find.byIcon(Icons.confirmation_num_outlined));
    await pumpUntil(
      tester,
      () => find.byType(MyReservationsPage).evaluate().isNotEmpty,
      reason: 'que se abra la pantalla de mis reservas',
    );
    await waitForData(tester);

    expect(
      find.byType(AsyncErrorView),
      findsNothing,
      reason: 'con sesión válida las reservas del usuario deben cargar',
    );
    expect(
      find.byType(ReservationCard).evaluate().isNotEmpty ||
          find.byType(AppEmptyState).evaluate().isNotEmpty,
      isTrue,
      reason: 'o hay reservas, o el estado vacío',
    );

    await tester.tap(find.byIcon(Icons.refresh));
    await waitForData(tester);
    expect(find.byType(AsyncErrorView), findsNothing);
  });

  testWidgets('cerrar sesión devuelve al login y no deja datos atrás', (
    WidgetTester tester,
  ) async {
    if (skipWithoutSession()) return;

    await ensureSignedIn();
    await launchAt(tester, EventsPage.routePath);
    expect(find.byType(EventsPage), findsOneWidget);
    await waitForData(tester);

    await tester.tap(find.byIcon(Icons.logout));
    await pumpUntil(
      tester,
      () => find.byType(LoginPage).evaluate().isNotEmpty,
      reason: 'que cerrar sesión devuelva al login',
    );

    expect(hasSession, isFalse);
  });
}
