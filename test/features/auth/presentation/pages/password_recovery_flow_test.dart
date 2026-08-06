import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/auth/di/auth_di.dart';
import 'package:eventix/features/auth/domain/enums/otp_purpose.dart';
import 'package:eventix/features/auth/domain/usecases/resend_otp.dart';
import 'package:eventix/features/auth/domain/usecases/send_password_reset.dart';
import 'package:eventix/features/auth/domain/usecases/sign_out.dart';
import 'package:eventix/features/auth/domain/usecases/update_password.dart';
import 'package:eventix/features/auth/domain/usecases/verify_otp.dart';
import 'package:eventix/features/auth/presentation/pages/login_page.dart';
import 'package:eventix/features/auth/presentation/pages/new_password_page.dart';
import 'package:eventix/features/auth/presentation/pages/new_password_success_page.dart';
import 'package:eventix/features/auth/presentation/pages/reset_password_request_page.dart';
import 'package:eventix/features/auth/presentation/pages/verify_code_page.dart';
import 'package:eventix/features/auth/presentation/widgets/verify_code_form.dart';
import 'package:eventix/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/pump_app.dart';

class _MockSendPasswordReset extends Mock implements SendPasswordReset {}

class _MockVerifyOtp extends Mock implements VerifyOtp {}

class _MockResendOtp extends Mock implements ResendOtp {}

class _MockUpdatePassword extends Mock implements UpdatePassword {}

class _MockSignOut extends Mock implements SignOut {}

void main() {
  late _MockSendPasswordReset sendReset;
  late _MockVerifyOtp verifyOtp;
  late _MockResendOtp resendOtp;
  late _MockUpdatePassword updatePassword;
  late _MockSignOut signOut;

  setUpAll(() => registerFallbackValue(OtpPurpose.recovery));

  setUp(() {
    sendReset = _MockSendPasswordReset();
    verifyOtp = _MockVerifyOtp();
    resendOtp = _MockResendOtp();
    updatePassword = _MockUpdatePassword();
    signOut = _MockSignOut();
  });

  List<Override> overrides() => <Override>[
    sendPasswordResetProvider.overrideWithValue(sendReset),
    verifyOtpProvider.overrideWithValue(verifyOtp),
    resendOtpProvider.overrideWithValue(resendOtp),
    updatePasswordProvider.overrideWithValue(updatePassword),
    signOutProvider.overrideWithValue(signOut),
  ];

  /// Todas las pantallas del flujo montadas juntas.
  List<RouteBase> routes() => <RouteBase>[
    GoRoute(
      path: ResetPasswordRequestPage.routePath,
      builder: (BuildContext context, GoRouterState state) =>
          const ResetPasswordRequestPage(),
    ),
    GoRoute(
      path: VerifyCodePage.routePath,
      builder: (BuildContext context, GoRouterState state) {
        final VerifyCodeArgs? args = state.extra as VerifyCodeArgs?;
        if (args == null) return const LoginPage();
        return VerifyCodePage(args: args);
      },
    ),
    GoRoute(
      path: NewPasswordPage.routePath,
      builder: (BuildContext context, GoRouterState state) =>
          const NewPasswordPage(),
    ),
    GoRoute(
      path: NewPasswordSuccessPage.routePath,
      builder: (BuildContext context, GoRouterState state) =>
          const NewPasswordSuccessPage(),
    ),
    stubRoute(LoginPage.routePath, 'LOGIN'),
    stubRoute(OnboardingPage.routePath, 'ONBOARDING'),
  ];

  Future<void> pumpFrom(WidgetTester tester, String location) => pumpRoutes(
    tester,
    initialLocation: location,
    overrides: overrides(),
    routes: routes(),
  );

  Future<void> requestCode(WidgetTester tester) async {
    await tester.enterText(
      find.byType(TextFormField),
      'victor@correo.com',
    );
    await tester.tap(find.widgetWithText(UiButton, 'Enviar código'));
    await tester.pumpAndSettle();
  }

  Future<void> typeCode(WidgetTester tester) async {
    for (int i = 0; i < VerifyCodeForm.otpLength; i++) {
      await tester.enterText(find.byType(TextField).at(i), '1');
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  group('pedir el código', () {
    testWidgets('un correo inválido no llega al backend', (
      WidgetTester tester,
    ) async {
      await pumpFrom(tester, ResetPasswordRequestPage.routePath);

      await tester.enterText(find.byType(TextFormField), 'victor');
      await tester.tap(find.widgetWithText(UiButton, 'Enviar código'));
      await tester.pump();

      expect(find.text('Correo inválido'), findsOneWidget);
      verifyNever(() => sendReset.call(email: any(named: 'email')));
    });

    testWidgets('con un correo válido avisa y pasa a la verificación', (
      WidgetTester tester,
    ) async {
      when(
        () => sendReset.call(email: any(named: 'email')),
      ).thenAnswer((_) async => const Success<void>(null));

      await pumpFrom(tester, ResetPasswordRequestPage.routePath);
      await requestCode(tester);

      verify(() => sendReset.call(email: 'victor@correo.com')).called(1);
      expect(find.text('Verifica tu correo'), findsOneWidget);
      expect(
        find.textContaining('victor@correo.com'),
        findsOneWidget,
        reason: 'la pantalla debe recordar a qué correo se envió',
      );
    });

    testWidgets('si el envío falla se queda en la pantalla y avisa', (
      WidgetTester tester,
    ) async {
      when(() => sendReset.call(email: any(named: 'email'))).thenAnswer(
        (_) async => const FailureResult<void>(
          AuthFailure('No existe una cuenta con ese correo'),
        ),
      );

      await pumpFrom(tester, ResetPasswordRequestPage.routePath);
      await tester.enterText(
        find.byType(TextFormField),
        'victor@correo.com',
      );
      await tester.tap(find.widgetWithText(UiButton, 'Enviar código'));
      await tester.pump();

      expect(
        find.widgetWithText(SnackBar, 'No existe una cuenta con ese correo'),
        findsOneWidget,
      );
      expect(find.text('Verifica tu correo'), findsNothing);
    });
  });

  group('verificar el código', () {
    Future<void> reachVerify(WidgetTester tester) async {
      when(
        () => sendReset.call(email: any(named: 'email')),
      ).thenAnswer((_) async => const Success<void>(null));
      await pumpFrom(tester, ResetPasswordRequestPage.routePath);
      await requestCode(tester);
    }

    testWidgets('un código correcto en recuperación abre la nueva clave', (
      WidgetTester tester,
    ) async {
      await reachVerify(tester);
      when(
        () => verifyOtp.call(
          email: any(named: 'email'),
          token: any(named: 'token'),
          purpose: any(named: 'purpose'),
        ),
      ).thenAnswer((_) async => const Success<void>(null));

      await typeCode(tester);

      verify(
        () => verifyOtp.call(
          email: 'victor@correo.com',
          token: '11111111',
          purpose: OtpPurpose.recovery,
        ),
      ).called(1);
      expect(
        find.widgetWithText(AppBar, 'Nueva contraseña'),
        findsOneWidget,
      );
    });

    testWidgets('un código malo avisa y no avanza', (
      WidgetTester tester,
    ) async {
      await reachVerify(tester);
      when(
        () => verifyOtp.call(
          email: any(named: 'email'),
          token: any(named: 'token'),
          purpose: any(named: 'purpose'),
        ),
      ).thenAnswer(
        (_) async =>
            const FailureResult<void>(AuthFailure('El código no es válido')),
      );

      await typeCode(tester);

      expect(
        find.widgetWithText(SnackBar, 'El código no es válido'),
        findsOneWidget,
      );
      expect(find.widgetWithText(AppBar, 'Nueva contraseña'), findsNothing);
    });

    testWidgets('reenviar el código confirma con un aviso', (
      WidgetTester tester,
    ) async {
      await reachVerify(tester);
      when(
        () => resendOtp.call(
          email: any(named: 'email'),
          purpose: any(named: 'purpose'),
        ),
      ).thenAnswer((_) async => const Success<void>(null));

      await tester.tap(find.text('Reenviar código'));
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(SnackBar, 'Código reenviado'),
        findsOneWidget,
      );
    });

    testWidgets('si el reenvío falla muestra el motivo', (
      WidgetTester tester,
    ) async {
      await reachVerify(tester);
      when(
        () => resendOtp.call(
          email: any(named: 'email'),
          purpose: any(named: 'purpose'),
        ),
      ).thenAnswer(
        (_) async => const FailureResult<void>(
          AuthFailure('Espera un momento antes de pedir otro código'),
        ),
      );

      await tester.tap(find.text('Reenviar código'));
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(
          SnackBar,
          'Espera un momento antes de pedir otro código',
        ),
        findsOneWidget,
      );
    });

    testWidgets('entrar a verificar sin datos cae al login, no a un error', (
      WidgetTester tester,
    ) async {
      await pumpFrom(tester, VerifyCodePage.routePath);
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
    });
  });

  group('nueva contraseña', () {
    testWidgets('contraseñas que no coinciden no llegan al backend', (
      WidgetTester tester,
    ) async {
      await pumpFrom(tester, NewPasswordPage.routePath);

      await tester.enterText(find.byType(TextFormField).at(0), 'secreta1');
      await tester.enterText(find.byType(TextFormField).at(1), 'secreta2');
      await tester.tap(find.widgetWithText(UiButton, 'Guardar contraseña'));
      await tester.pump();

      expect(find.text('Las contraseñas no coinciden'), findsOneWidget);
      verifyNever(
        () => updatePassword.call(newPassword: any(named: 'newPassword')),
      );
    });

    testWidgets('guardar bien lleva a la confirmación', (
      WidgetTester tester,
    ) async {
      when(
        () => updatePassword.call(newPassword: any(named: 'newPassword')),
      ).thenAnswer((_) async => const Success<void>(null));

      await pumpFrom(tester, NewPasswordPage.routePath);
      await tester.enterText(find.byType(TextFormField).at(0), 'secreta1');
      await tester.enterText(find.byType(TextFormField).at(1), 'secreta1');
      await tester.tap(find.widgetWithText(UiButton, 'Guardar contraseña'));
      await tester.pumpAndSettle();

      verify(
        () => updatePassword.call(newPassword: 'secreta1'),
      ).called(1);
      expect(find.text('¡Contraseña actualizada!'), findsOneWidget);
    });

    testWidgets('si guardar falla avisa y no navega', (
      WidgetTester tester,
    ) async {
      when(
        () => updatePassword.call(newPassword: any(named: 'newPassword')),
      ).thenAnswer(
        (_) async => const FailureResult<void>(UnauthorizedFailure()),
      );

      await pumpFrom(tester, NewPasswordPage.routePath);
      await tester.enterText(find.byType(TextFormField).at(0), 'secreta1');
      await tester.enterText(find.byType(TextFormField).at(1), 'secreta1');
      await tester.tap(find.widgetWithText(UiButton, 'Guardar contraseña'));
      await tester.pump();

      expect(
        find.widgetWithText(SnackBar, 'Sesión expirada'),
        findsOneWidget,
      );
      expect(find.text('¡Contraseña actualizada!'), findsNothing);
    });
  });

  group('confirmación', () {
    testWidgets('cierra la sesión temporal antes de volver al login', (
      WidgetTester tester,
    ) async {
      when(signOut.call).thenAnswer((_) async => const Success<void>(null));

      await pumpFrom(tester, NewPasswordSuccessPage.routePath);
      await tester.tap(
        find.widgetWithText(UiButton, 'Ir a iniciar sesión'),
      );
      await tester.pumpAndSettle();

      // El reset deja sesión abierta: sin cerrarla el usuario sigue dentro.
      verify(signOut.call).called(1);
      expect(find.text('LOGIN'), findsOneWidget);
    });

    testWidgets('si cerrar sesión falla avisa y no va al login', (
      WidgetTester tester,
    ) async {
      when(signOut.call).thenAnswer(
        (_) async => const FailureResult<void>(ConnectionFailure()),
      );

      await pumpFrom(tester, NewPasswordSuccessPage.routePath);
      await tester.tap(
        find.widgetWithText(UiButton, 'Ir a iniciar sesión'),
      );
      await tester.pump();

      expect(
        find.widgetWithText(SnackBar, 'Sin conexión a internet'),
        findsOneWidget,
      );
      expect(find.text('LOGIN'), findsNothing);
    });
  });
}
