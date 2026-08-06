import 'package:eventix/features/auth/domain/enums/otp_purpose.dart';
import 'package:eventix/features/auth/presentation/pages/login_page.dart';
import 'package:eventix/features/auth/presentation/pages/new_password_page.dart';
import 'package:eventix/features/auth/presentation/pages/new_password_success_page.dart';
import 'package:eventix/features/auth/presentation/pages/register_page.dart';
import 'package:eventix/features/auth/presentation/pages/reset_password_request_page.dart';
import 'package:eventix/features/auth/presentation/pages/verify_code_page.dart';
import 'package:eventix/features/auth/routes/auth_routes.dart';
import 'package:eventix/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../helpers/pump_app.dart';

/// Monta la lista real que registra el router, no un `GoRoute` del test.
void main() {
  Future<void> pumpAt(
    WidgetTester tester,
    String location, {
    Object? extra,
  }) => pumpRoutes(
    tester,
    initialLocation: location,
    initialExtra: extra,
    routes: authRoutes,
  );

  testWidgets('/login abre el login', (WidgetTester tester) async {
    await pumpAt(tester, LoginPage.routePath);

    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('/register abre el registro', (WidgetTester tester) async {
    await pumpAt(tester, RegisterPage.routePath);

    expect(find.byType(RegisterPage), findsOneWidget);
  });

  testWidgets('/reset-password abre la solicitud de recuperación', (
    WidgetTester tester,
  ) async {
    await pumpAt(tester, ResetPasswordRequestPage.routePath);

    expect(find.byType(ResetPasswordRequestPage), findsOneWidget);
  });

  testWidgets('/new-password abre el formulario de contraseña nueva', (
    WidgetTester tester,
  ) async {
    await pumpAt(tester, NewPasswordPage.routePath);

    expect(find.byType(NewPasswordPage), findsOneWidget);
  });

  testWidgets('/new-password/success abre la confirmación', (
    WidgetTester tester,
  ) async {
    await pumpAt(tester, NewPasswordSuccessPage.routePath);

    expect(find.byType(NewPasswordSuccessPage), findsOneWidget);
  });

  testWidgets('/onboarding abre el onboarding', (WidgetTester tester) async {
    await pumpAt(tester, OnboardingPage.routePath);

    expect(find.byType(OnboardingPage), findsOneWidget);
  });

  group('/verify', () {
    testWidgets('con argumentos abre la verificación de código', (
      WidgetTester tester,
    ) async {
      await pumpAt(
        tester,
        VerifyCodePage.routePath,
        extra: const VerifyCodeArgs(
          email: 'a@b.com',
          purpose: OtpPurpose.signup,
        ),
      );

      expect(find.byType(VerifyCodePage), findsOneWidget);
      expect(find.textContaining('a@b.com'), findsOneWidget);
    });

    testWidgets('sin argumentos cae al login en vez de reventar', (
      WidgetTester tester,
    ) async {
      // `extra` se pierde al entrar por deep link; sin el fallback el builder
      // haría un cast nulo y la app abriría en rojo.
      await pumpAt(tester, VerifyCodePage.routePath);

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(VerifyCodePage), findsNothing);
    });
  });

  test('las rutas de auth no chocan entre sí', () {
    final List<String> paths = <String>[
      for (final RouteBase route in authRoutes) (route as GoRoute).path,
    ];

    expect(paths.toSet(), hasLength(paths.length));
  });
}
