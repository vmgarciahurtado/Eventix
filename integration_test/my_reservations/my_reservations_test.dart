import '../exports.dart';

void main() {
  testWidgets('mis reservas: lista lo del usuario en sesión y refresca', (
    WidgetTester tester,
  ) async {
    if (skipWithoutSession()) return;

    await goTo(tester, EventsPage.routePath);
    await settle(tester, timeout: const Duration(seconds: 20));

    await tester.tap(find.byIcon(Icons.confirmation_num_outlined));
    await settle(tester, timeout: const Duration(seconds: 20));

    expect(find.byType(MyReservationsPage), findsOneWidget);
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
    await settle(tester, timeout: const Duration(seconds: 20));
    expect(find.byType(AsyncErrorView), findsNothing);
  });

  testWidgets('cerrar sesión devuelve al login y no deja datos atrás', (
    WidgetTester tester,
  ) async {
    if (skipWithoutSession()) return;

    await goTo(tester, EventsPage.routePath);
    await settle(tester, timeout: const Duration(seconds: 20));

    await tester.tap(find.byIcon(Icons.logout));
    await settle(tester, timeout: const Duration(seconds: 20));

    expect(find.byType(LoginPage), findsOneWidget);
    expect(hasSession, isFalse);
  });
}
