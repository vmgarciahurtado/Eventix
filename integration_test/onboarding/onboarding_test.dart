import '../exports.dart';

void main() {
  testWidgets('onboarding: se completa y entra al catálogo', (
    WidgetTester tester,
  ) async {
    if (skipWithoutSession()) return;

    await ensureSignedIn();
    await launchAt(tester, OnboardingPage.routePath);

    expect(find.byType(OnboardingPage), findsOneWidget);
    expect(find.text('Descubre eventos'), findsOneWidget);

    // Avanzar por las tres diapositivas hasta que el botón cambie.
    while (find.widgetWithText(UiButton, 'Siguiente').evaluate().isNotEmpty) {
      await tester.tap(find.widgetWithText(UiButton, 'Siguiente'));
      await settle(tester, timeout: const Duration(seconds: 3));
    }

    expect(find.widgetWithText(UiButton, 'Comenzar'), findsOneWidget);
    await tester.tap(find.widgetWithText(UiButton, 'Comenzar'));
    // Aunque el guardado falle, el onboarding nunca debe dejar atrapado.
    await pumpUntil(
      tester,
      () => find.byType(EventsPage).evaluate().isNotEmpty,
      reason: 'que el onboarding deje entrar al catálogo',
    );
  });
}
