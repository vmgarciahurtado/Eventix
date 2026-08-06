import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/auth/di/auth_di.dart';
import 'package:eventix/features/auth/domain/enums/otp_purpose.dart';
import 'package:eventix/features/auth/domain/usecases/resend_otp.dart';
import 'package:eventix/features/auth/domain/usecases/verify_otp.dart';
import 'package:eventix/features/auth/presentation/pages/new_password_page.dart';
import 'package:eventix/features/auth/presentation/pages/verify_code_page.dart';
import 'package:eventix/features/auth/presentation/widgets/verify_code_form.dart';
import 'package:eventix/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/pump_app.dart';

class _MockVerifyOtp extends Mock implements VerifyOtp {}

class _MockResendOtp extends Mock implements ResendOtp {}

/// La misma pantalla sirve para dos flujos y el propósito decide a dónde sale.
void main() {
  late _MockVerifyOtp verifyOtp;
  late _MockResendOtp resendOtp;

  setUpAll(() => registerFallbackValue(OtpPurpose.signup));

  setUp(() {
    verifyOtp = _MockVerifyOtp();
    resendOtp = _MockResendOtp();
    when(
      () => verifyOtp.call(
        email: any(named: 'email'),
        token: any(named: 'token'),
        purpose: any(named: 'purpose'),
      ),
    ).thenAnswer((_) async => const Success<void>(null));
  });

  Future<void> pumpVerify(WidgetTester tester, OtpPurpose purpose) =>
      pumpRoutes(
        tester,
        initialLocation: VerifyCodePage.routePath,
        initialExtra: VerifyCodeArgs(
          email: 'victor@correo.com',
          purpose: purpose,
        ),
        overrides: <Override>[
          verifyOtpProvider.overrideWithValue(verifyOtp),
          resendOtpProvider.overrideWithValue(resendOtp),
        ],
        routes: <RouteBase>[
          GoRoute(
            path: VerifyCodePage.routePath,
            builder: (BuildContext context, GoRouterState state) =>
                VerifyCodePage(args: state.extra! as VerifyCodeArgs),
          ),
          stubRoute(OnboardingPage.routePath, 'ONBOARDING'),
          stubRoute(NewPasswordPage.routePath, 'NUEVA CLAVE'),
        ],
      );

  Future<void> typeCode(WidgetTester tester) async {
    for (int i = 0; i < VerifyCodeForm.otpLength; i++) {
      await tester.enterText(find.byType(TextField).at(i), '1');
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  testWidgets('verificar el registro entra al onboarding', (
    WidgetTester tester,
  ) async {
    await pumpVerify(tester, OtpPurpose.signup);
    await typeCode(tester);

    verify(
      () => verifyOtp.call(
        email: 'victor@correo.com',
        token: '1' * VerifyCodeForm.otpLength,
        purpose: OtpPurpose.signup,
      ),
    ).called(1);
    // Una cuenta recién verificada no ha visto el onboarding.
    expect(find.text('ONBOARDING'), findsOneWidget);
    expect(find.text('NUEVA CLAVE'), findsNothing);
  });

  testWidgets('verificar una recuperación va a la contraseña nueva', (
    WidgetTester tester,
  ) async {
    await pumpVerify(tester, OtpPurpose.recovery);
    await typeCode(tester);

    // Mismo código y misma pantalla, salida distinta.
    expect(find.text('NUEVA CLAVE'), findsOneWidget);
    expect(find.text('ONBOARDING'), findsNothing);
  });

  testWidgets('un código incorrecto avisa y no deja pasar', (
    WidgetTester tester,
  ) async {
    when(
      () => verifyOtp.call(
        email: any(named: 'email'),
        token: any(named: 'token'),
        purpose: any(named: 'purpose'),
      ),
    ).thenAnswer(
      (_) async => const FailureResult<void>(AuthFailure('Código inválido')),
    );

    await pumpVerify(tester, OtpPurpose.signup);
    await typeCode(tester);

    expect(find.widgetWithText(SnackBar, 'Código inválido'), findsOneWidget);
    expect(find.text('ONBOARDING'), findsNothing);
  });
}
