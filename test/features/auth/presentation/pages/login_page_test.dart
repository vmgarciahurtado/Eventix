import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/core/widgets/app_character.dart';
import 'package:eventix/core/widgets/app_icon_badge.dart';
import 'package:eventix/features/auth/di/auth_di.dart';
import 'package:eventix/features/auth/domain/enums/post_auth_destination.dart';
import 'package:eventix/features/auth/domain/usecases/resolve_post_auth_destination.dart';
import 'package:eventix/features/auth/domain/usecases/sign_in.dart';
import 'package:eventix/features/auth/presentation/pages/login_page.dart';
import 'package:eventix/features/auth/presentation/pages/register_page.dart';
import 'package:eventix/features/auth/presentation/pages/reset_password_request_page.dart';
import 'package:eventix/features/events/presentation/pages/events_page.dart';
import 'package:eventix/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/pump_app.dart';

class _MockSignIn extends Mock implements SignIn {}

class _MockResolvePostAuthDestination extends Mock
    implements ResolvePostAuthDestination {}

void main() {
  late _MockSignIn signIn;
  late _MockResolvePostAuthDestination resolveDestination;

  setUp(() {
    signIn = _MockSignIn();
    resolveDestination = _MockResolvePostAuthDestination();
  });

  Future<void> pumpLogin(WidgetTester tester) => pumpRoutes(
    tester,
    initialLocation: LoginPage.routePath,
    overrides: <Override>[
      signInProvider.overrideWithValue(signIn),
      resolvePostAuthDestinationProvider.overrideWithValue(resolveDestination),
    ],
    routes: <RouteBase>[
      GoRoute(
        path: LoginPage.routePath,
        builder: (BuildContext context, GoRouterState state) =>
            const LoginPage(),
      ),
      stubRoute(RegisterPage.routePath, 'REGISTRO'),
      stubRoute(ResetPasswordRequestPage.routePath, 'RECUPERAR'),
      stubRoute(EventsPage.routePath, 'CATALOGO'),
      stubRoute(OnboardingPage.routePath, 'ONBOARDING'),
    ],
  );

  Future<void> fillAndSubmit(WidgetTester tester) async {
    await tester.enterText(
      find.byType(TextFormField).first,
      'victor@correo.com',
    );
    await tester.enterText(find.byType(TextFormField).last, 'secreta1');
    await tester.tap(find.widgetWithText(UiButton, 'Iniciar sesión'));
    await tester.pumpAndSettle();
  }

  void mockSignIn(Result<void> result) => when(
    () => signIn.call(
      email: any(named: 'email'),
      password: any(named: 'password'),
    ),
  ).thenAnswer((_) async => result);

  testWidgets('la mascota es el protagonista y el icono queda como chip', (
    WidgetTester tester,
  ) async {
    await pumpLogin(tester);

    expect(find.byType(AppCharacter), findsOneWidget);
    expect(find.byType(AppIconBadge), findsOneWidget);
    expect(find.text('Bienvenido a Eventix'), findsOneWidget);
  });

  testWidgets('autenticarse con onboarding pendiente lleva al onboarding', (
    WidgetTester tester,
  ) async {
    mockSignIn(const Success<void>(null));
    when(
      resolveDestination.call,
    ).thenAnswer((_) async => PostAuthDestination.onboarding);

    await pumpLogin(tester);
    await fillAndSubmit(tester);

    expect(find.text('ONBOARDING'), findsOneWidget);
  });

  testWidgets('autenticarse con onboarding hecho lleva al catálogo', (
    WidgetTester tester,
  ) async {
    mockSignIn(const Success<void>(null));
    when(
      resolveDestination.call,
    ).thenAnswer((_) async => PostAuthDestination.home);

    await pumpLogin(tester);
    await fillAndSubmit(tester);

    expect(find.text('CATALOGO'), findsOneWidget);
  });

  testWidgets('credenciales malas avisan y dejan al usuario en el login', (
    WidgetTester tester,
  ) async {
    mockSignIn(
      const FailureResult<void>(AuthFailure('Correo o contraseña inválidos')),
    );

    await pumpLogin(tester);
    await tester.enterText(
      find.byType(TextFormField).first,
      'victor@correo.com',
    );
    await tester.enterText(find.byType(TextFormField).last, 'secreta1');
    await tester.tap(find.widgetWithText(UiButton, 'Iniciar sesión'));
    await tester.pump();

    expect(
      find.widgetWithText(SnackBar, 'Correo o contraseña inválidos'),
      findsOneWidget,
    );
    expect(find.text('Bienvenido a Eventix'), findsOneWidget);
    verifyNever(resolveDestination.call);
  });

  testWidgets('"regístrate" abre el registro', (WidgetTester tester) async {
    await pumpLogin(tester);

    // En una pantalla de 800 de alto el enlace queda bajo el pliegue.
    await tester.ensureVisible(find.text('Regístrate'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Regístrate'));
    await tester.pumpAndSettle();

    expect(find.text('REGISTRO'), findsOneWidget);
  });

  testWidgets('"olvidé mi contraseña" abre la recuperación', (
    WidgetTester tester,
  ) async {
    await pumpLogin(tester);

    await tester.tap(find.text('¿Olvidaste tu contraseña?'));
    await tester.pumpAndSettle();

    expect(find.text('RECUPERAR'), findsOneWidget);
  });
}
