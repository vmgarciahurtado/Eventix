import '../exports.dart';

void main() {
  testWidgets('login: rechaza datos inválidos y autentica los válidos', (
    WidgetTester tester,
  ) async {
    if (skipWithoutSession()) return;

    await clearSession();
    await goTo(tester, LoginPage.routePath);

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(UiTextField), findsNWidgets(2));

    final Finder email = find.byType(TextFormField).first;
    final Finder password = find.byType(TextFormField).last;
    final Finder submit = find.widgetWithText(UiButton, 'Iniciar sesión');

    // Un correo mal formado se detiene en el cliente: no gasta una llamada.
    await tester.enterText(email, 'victor');
    await tester.enterText(password, '123456');
    await tester.tap(submit);
    await tester.pump();
    expect(find.text('Correo inválido'), findsOneWidget);
    expect(hasSession, isFalse);

    // Credenciales bien formadas pero falsas: el backend las rechaza.
    await tester.enterText(
      email,
      'no-existe-${DateTime.now().year}@eventix.co',
    );
    await tester.enterText(password, 'contrasena-incorrecta');
    await tester.tap(submit);
    await settle(tester);
    expect(find.byType(LoginPage), findsOneWidget);
    expect(hasSession, isFalse);

    // Las credenciales reales sí abren sesión y sacan del login.
    await tester.enterText(email, TestCredentials.email);
    await tester.enterText(password, TestCredentials.password);
    await tester.tap(submit);
    await settle(tester, timeout: const Duration(seconds: 20));

    expect(hasSession, isTrue);
    expect(find.byType(LoginPage), findsNothing);
    // Según el estado del perfil aterriza en el onboarding o en el catálogo.
    expect(
      find.byType(OnboardingPage).evaluate().isNotEmpty ||
          find.byType(EventsPage).evaluate().isNotEmpty,
      isTrue,
      reason: 'tras autenticarse debe estar en el onboarding o en el catálogo',
    );
  });
}
