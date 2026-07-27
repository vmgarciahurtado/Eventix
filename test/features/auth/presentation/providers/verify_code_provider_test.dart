import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/auth/di/auth_di.dart';
import 'package:eventix/features/auth/domain/enums/otp_purpose.dart';
import 'package:eventix/features/auth/domain/usecases/resend_otp.dart';
import 'package:eventix/features/auth/domain/usecases/verify_otp.dart';
import 'package:eventix/features/auth/presentation/providers/verify_code_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockVerifyOtp extends Mock implements VerifyOtp {}

class _MockResendOtp extends Mock implements ResendOtp {}

void main() {
  late _MockVerifyOtp verifyOtp;
  late _MockResendOtp resendOtp;
  late ProviderContainer container;

  setUpAll(() => registerFallbackValue(OtpPurpose.signup));

  setUp(() {
    verifyOtp = _MockVerifyOtp();
    resendOtp = _MockResendOtp();
    container = ProviderContainer(
      overrides: <Override>[
        verifyOtpProvider.overrideWithValue(verifyOtp),
        resendOtpProvider.overrideWithValue(resendOtp),
      ],
    );
    addTearDown(container.dispose);
  });

  Future<void> verifyCode() => container
      .read(verifyCodeProvider.notifier)
      .verify(
        email: 'a@b.com',
        token: '123456',
        purpose: OtpPurpose.signup,
      );

  test('expone AsyncData al verificar con Success', () async {
    when(
      () => verifyOtp.call(
        email: any(named: 'email'),
        token: any(named: 'token'),
        purpose: any(named: 'purpose'),
      ),
    ).thenAnswer((_) async => const Success<void>(null));

    await verifyCode();

    expect(container.read(verifyCodeProvider), isA<AsyncData<void>>());
  });

  test(
    'expone AsyncError con el Failure cuando el código es inválido',
    () async {
      when(
        () => verifyOtp.call(
          email: any(named: 'email'),
          token: any(named: 'token'),
          purpose: any(named: 'purpose'),
        ),
      ).thenAnswer(
        (_) async => const FailureResult<void>(AuthFailure('Código inválido.')),
      );

      await verifyCode();

      final AsyncValue<void> state = container.read(verifyCodeProvider);
      expect(state, isA<AsyncError<void>>());
      expect((state as AsyncError<void>).error, isA<AuthFailure>());
    },
  );

  test('resend delega en el usecase y devuelve su Result', () async {
    when(
      () => resendOtp.call(
        email: any(named: 'email'),
        purpose: any(named: 'purpose'),
      ),
    ).thenAnswer((_) async => const Success<void>(null));

    final Result<void> result = await container
        .read(verifyCodeProvider.notifier)
        .resend(email: 'a@b.com', purpose: OtpPurpose.recovery);

    expect(result, isA<Success<void>>());
    verify(
      () => resendOtp.call(
        email: 'a@b.com',
        purpose: OtpPurpose.recovery,
      ),
    ).called(1);
  });
}
