import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/auth/domain/enums/otp_purpose.dart';
import 'package:eventix/features/auth/domain/repositories/auth_repository.dart';
import 'package:eventix/features/auth/domain/usecases/register_user.dart';
import 'package:eventix/features/auth/domain/usecases/resend_otp.dart';
import 'package:eventix/features/auth/domain/usecases/send_password_reset.dart';
import 'package:eventix/features/auth/domain/usecases/sign_in.dart';
import 'package:eventix/features/auth/domain/usecases/sign_out.dart';
import 'package:eventix/features/auth/domain/usecases/update_password.dart';
import 'package:eventix/features/auth/domain/usecases/verify_otp.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

/// Delegados de una línea. `ResolvePostAuthDestination` tiene lógica propia y
/// vive aparte, en `resolve_post_auth_destination_test.dart`.
void main() {
  late _MockAuthRepository repository;

  setUpAll(() => registerFallbackValue(OtpPurpose.signup));

  setUp(() => repository = _MockAuthRepository());

  group('SignIn', () {
    test('entrega las credenciales sin tocarlas', () async {
      when(
        () => repository.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => const Success<void>(null));

      final Result<void> result = await SignIn(
        repository,
      ).call(email: 'a@b.com', password: '123456');

      expect(result, isA<Success<void>>());
      verify(
        () => repository.signIn(email: 'a@b.com', password: '123456'),
      ).called(1);
    });

    test('un rechazo de credenciales no se convierte en éxito', () async {
      when(
        () => repository.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => const FailureResult<void>(AuthFailure('Incorrectos')),
      );

      expect(
        await SignIn(repository).call(email: 'a@b.com', password: 'mala'),
        isA<FailureResult<void>>(),
      );
    });
  });

  group('RegisterUser', () {
    test('entrega los cuatro campos en su sitio', () async {
      when(
        () => repository.register(
          email: any(named: 'email'),
          password: any(named: 'password'),
          firstName: any(named: 'firstName'),
          lastName: any(named: 'lastName'),
        ),
      ).thenAnswer((_) async => const Success<void>(null));

      await RegisterUser(repository).call(
        email: 'a@b.com',
        password: '123456',
        firstName: 'Victor',
        lastName: 'García',
      );

      verify(
        () => repository.register(
          email: 'a@b.com',
          password: '123456',
          firstName: 'Victor',
          lastName: 'García',
        ),
      ).called(1);
    });
  });

  group('VerifyOtp', () {
    test('conserva el propósito junto con el código', () async {
      when(
        () => repository.verifyOtp(
          email: any(named: 'email'),
          token: any(named: 'token'),
          purpose: any(named: 'purpose'),
        ),
      ).thenAnswer((_) async => const Success<void>(null));

      await VerifyOtp(repository).call(
        email: 'a@b.com',
        token: '123456',
        purpose: OtpPurpose.recovery,
      );

      // Un código de recuperación verificado como de registro se rechaza.
      verify(
        () => repository.verifyOtp(
          email: 'a@b.com',
          token: '123456',
          purpose: OtpPurpose.recovery,
        ),
      ).called(1);
    });
  });

  group('ResendOtp', () {
    test('conserva el propósito, que decide qué correo se manda', () async {
      when(
        () => repository.resendOtp(
          email: any(named: 'email'),
          purpose: any(named: 'purpose'),
        ),
      ).thenAnswer((_) async => const Success<void>(null));

      await ResendOtp(
        repository,
      ).call(email: 'a@b.com', purpose: OtpPurpose.signup);

      verify(
        () => repository.resendOtp(
          email: 'a@b.com',
          purpose: OtpPurpose.signup,
        ),
      ).called(1);
    });
  });

  group('SendPasswordReset', () {
    test('pide el correo de recuperación para esa cuenta', () async {
      when(
        () => repository.sendPasswordReset(email: any(named: 'email')),
      ).thenAnswer((_) async => const Success<void>(null));

      final Result<void> result = await SendPasswordReset(
        repository,
      ).call(email: 'a@b.com');

      expect(result, isA<Success<void>>());
      verify(() => repository.sendPasswordReset(email: 'a@b.com')).called(1);
    });
  });

  group('UpdatePassword', () {
    test('entrega la contraseña nueva', () async {
      when(
        () => repository.updatePassword(
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer((_) async => const Success<void>(null));

      await UpdatePassword(repository).call(newPassword: 'clave-nueva');

      verify(
        () => repository.updatePassword(newPassword: 'clave-nueva'),
      ).called(1);
    });

    test('un fallo llega tal cual a quien lo pidió', () async {
      when(
        () => repository.updatePassword(
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer(
        (_) async => const FailureResult<void>(UnauthorizedFailure()),
      );

      final Result<void> result = await UpdatePassword(
        repository,
      ).call(newPassword: 'clave-nueva');

      expect(
        (result as FailureResult<void>).failure,
        isA<UnauthorizedFailure>(),
      );
    });
  });

  group('SignOut', () {
    test('cierra la sesión una sola vez', () async {
      when(
        repository.signOut,
      ).thenAnswer((_) async => const Success<void>(null));

      expect(await SignOut(repository).call(), isA<Success<void>>());
      verify(repository.signOut).called(1);
    });

    test('un fallo al cerrar sesión se reporta, no se traga', () async {
      when(
        repository.signOut,
      ).thenAnswer((_) async => const FailureResult<void>(ServerFailure()));

      expect(await SignOut(repository).call(), isA<FailureResult<void>>());
    });
  });
}
