import '../exports.dart';

void main() {
  testWidgets('splash: arranca, muestra la marca y resuelve la sesión', (
    WidgetTester tester,
  ) async {
    await clearSession();
    await tester.pumpWidget(const ProviderScope(child: MainApp()));

    // El primer frame es el splash: la marca aparece antes de cualquier red.
    expect(find.byType(SplashPage), findsOneWidget);
    expect(find.byType(UiLoader), findsOneWidget);

    await settle(tester);

    // Sin sesión el splash tiene que sacar al usuario de ahí, al login.
    expect(find.byType(SplashPage), findsNothing);
    expect(find.byType(LoginPage), findsOneWidget);
  });
}
