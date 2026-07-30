import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/core/widgets/app_logo.dart';
import 'package:eventix/features/auth/di/auth_di.dart';
import 'package:eventix/features/auth/domain/usecases/register_user.dart';
import 'package:eventix/features/auth/presentation/pages/register_page.dart';
import 'package:eventix/features/auth/presentation/pages/verify_code_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/pump_app.dart';

class _MockRegisterUser extends Mock implements RegisterUser {}

void main() {
  late _MockRegisterUser registerUser;

  setUp(() => registerUser = _MockRegisterUser());

  Future<void> pumpRegister(WidgetTester tester) => pumpRoutes(
    tester,
    initialLocation: RegisterPage.routePath,
    overrides: <Override>[
      registerUserProvider.overrideWithValue(registerUser),
    ],
    routes: <RouteBase>[
      GoRoute(
        path: RegisterPage.routePath,
        builder: (BuildContext context, GoRouterState state) =>
            const RegisterPage(),
      ),
      stubRoute(VerifyCodePage.routePath, 'VERIFICAR'),
    ],
  );

  Future<void> fillAndSubmit(WidgetTester tester) async {
    final Finder fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Victor');
    await tester.enterText(fields.at(1), 'García');
    await tester.enterText(fields.at(2), 'victor@correo.com');
    await tester.enterText(fields.at(3), 'secreta1');
    await tester.enterText(fields.at(4), 'secreta1');
    await tester.ensureVisible(find.byType(UiCheckOption));
    await tester.pumpAndSettle();
    await tester.tapAt(
      tester.getTopLeft(find.byType(UiCheckOption)) + const Offset(12, 12),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(UiButton, 'Registrarme'));
  }

  void mockRegister(Result<void> result) => when(
    () => registerUser.call(
      email: any(named: 'email'),
      password: any(named: 'password'),
      firstName: any(named: 'firstName'),
      lastName: any(named: 'lastName'),
    ),
  ).thenAnswer((_) async => result);

  testWidgets('muestra el lockup de marca y el formulario', (
    WidgetTester tester,
  ) async {
    await pumpRegister(tester);

    expect(find.byType(AppLogo), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'Crear cuenta'), findsOneWidget);
    expect(find.byType(UiTextField), findsNWidgets(5));
  });

  testWidgets('registrarse pasa a verificar el correo', (
    WidgetTester tester,
  ) async {
    mockRegister(const Success<void>(null));

    await pumpRegister(tester);
    await fillAndSubmit(tester);
    await tester.pumpAndSettle();

    verify(
      () => registerUser.call(
        email: 'victor@correo.com',
        password: 'secreta1',
        firstName: 'Victor',
        lastName: 'García',
      ),
    ).called(1);
    expect(find.text('VERIFICAR'), findsOneWidget);
  });

  testWidgets('un correo ya registrado avisa y no avanza', (
    WidgetTester tester,
  ) async {
    mockRegister(
      const FailureResult<void>(
        ValidationFailure('Ese correo ya está registrado'),
      ),
    );

    await pumpRegister(tester);
    await fillAndSubmit(tester);
    await tester.pump();

    expect(
      find.widgetWithText(SnackBar, 'Ese correo ya está registrado'),
      findsOneWidget,
    );
    expect(find.text('VERIFICAR'), findsNothing);
  });
}
