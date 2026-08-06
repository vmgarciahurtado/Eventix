import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/auth/domain/enums/otp_purpose.dart';
import 'package:eventix/features/auth/infrastructure/datasources/auth_datasource.dart';
import 'package:eventix/features/auth/infrastructure/repositories/auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthDatasource extends Mock implements AuthDatasource {}

/// Envuelve al datasource en `Result`: ni pierde parámetros por el camino ni
/// deja escapar excepciones sin convertirlas en `Failure`.
void main() {
  late _MockAuthDatasource datasource;
  late AuthRepositoryImpl repository;

  setUpAll(() => registerFallbackValue(OtpPurpose.signup));

  setUp(() {
    datasource = _MockAuthDatasource();
    repository = AuthRepositoryImpl(datasource);
  });

  group('signIn', () {
    test('devuelve Success cuando el datasource completa', () async {
      when(
        () => datasource.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async {});

      final Result<void> result = await repository.signIn(
        email: 'a@b.com',
        password: '123456',
      );

      expect(result, isA<Success<void>>());
      verify(
        () => datasource.signIn(email: 'a@b.com', password: '123456'),
      ).called(1);
    });

    test('devuelve FailureResult cuando el datasource lanza', () async {
      when(
        () => datasource.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const AuthFailure('Correo o contraseña incorrectos.'));

      final Result<void> result = await repository.signIn(
        email: 'a@b.com',
        password: 'bad',
      );

      expect(result, isA<FailureResult<void>>());
      expect((result as FailureResult<void>).failure, isA<AuthFailure>());
    });
  });

  group('register', () {
    test('pasa los cuatro datos del formulario', () async {
      when(
        () => datasource.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          firstName: any(named: 'firstName'),
          lastName: any(named: 'lastName'),
        ),
      ).thenAnswer((_) async {});

      final Result<void> result = await repository.register(
        email: 'a@b.com',
        password: '123456',
        firstName: 'Victor',
        lastName: 'García',
      );

      expect(result, isA<Success<void>>());
      // Nombre y apellido son del mismo tipo: intercambiarlos compila.
      verify(
        () => datasource.signUp(
          email: 'a@b.com',
          password: '123456',
          firstName: 'Victor',
          lastName: 'García',
        ),
      ).called(1);
    });

    test('un correo ya registrado llega como Failure', () async {
      when(
        () => datasource.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          firstName: any(named: 'firstName'),
          lastName: any(named: 'lastName'),
        ),
      ).thenThrow(const AuthFailure('Ese correo ya está registrado.'));

      final Result<void> result = await repository.register(
        email: 'a@b.com',
        password: '123456',
        firstName: 'Victor',
        lastName: 'García',
      );

      expect((result as FailureResult<void>).failure, isA<AuthFailure>());
    });
  });

  group('verifyOtp', () {
    test('delega en el datasource con el propósito que le dieron', () async {
      when(
        () => datasource.verifyOtp(
          email: any(named: 'email'),
          token: any(named: 'token'),
          purpose: any(named: 'purpose'),
        ),
      ).thenAnswer((_) async {});

      final Result<void> result = await repository.verifyOtp(
        email: 'a@b.com',
        token: '123456',
        purpose: OtpPurpose.signup,
      );

      expect(result, isA<Success<void>>());
      verify(
        () => datasource.verifyOtp(
          email: 'a@b.com',
          token: '123456',
          purpose: OtpPurpose.signup,
        ),
      ).called(1);
    });

    test('un código vencido llega como Failure', () async {
      when(
        () => datasource.verifyOtp(
          email: any(named: 'email'),
          token: any(named: 'token'),
          purpose: any(named: 'purpose'),
        ),
      ).thenThrow(const AuthFailure('El código expiró.'));

      final Result<void> result = await repository.verifyOtp(
        email: 'a@b.com',
        token: '000000',
        purpose: OtpPurpose.recovery,
      );

      expect((result as FailureResult<void>).failure, isA<AuthFailure>());
    });
  });

  group('resendOtp', () {
    test('conserva el propósito, que decide qué correo se manda', () async {
      when(
        () => datasource.resendOtp(
          email: any(named: 'email'),
          purpose: any(named: 'purpose'),
        ),
      ).thenAnswer((_) async {});

      final Result<void> result = await repository.resendOtp(
        email: 'a@b.com',
        purpose: OtpPurpose.recovery,
      );

      expect(result, isA<Success<void>>());
      // Con el propósito equivocado Supabase manda el correo del otro flujo.
      verify(
        () => datasource.resendOtp(
          email: 'a@b.com',
          purpose: OtpPurpose.recovery,
        ),
      ).called(1);
    });
  });

  group('sendPasswordReset', () {
    test('devuelve Success cuando el correo sale', () async {
      when(
        () => datasource.sendPasswordReset(email: any(named: 'email')),
      ).thenAnswer((_) async {});

      final Result<void> result = await repository.sendPasswordReset(
        email: 'a@b.com',
      );

      expect(result, isA<Success<void>>());
      verify(() => datasource.sendPasswordReset(email: 'a@b.com')).called(1);
    });

    test('el límite de envíos llega como Failure', () async {
      when(
        () => datasource.sendPasswordReset(email: any(named: 'email')),
      ).thenThrow(const AuthFailure('Demasiados intentos.'));

      final Result<void> result = await repository.sendPasswordReset(
        email: 'a@b.com',
      );

      expect((result as FailureResult<void>).failure, isA<AuthFailure>());
    });
  });

  group('updatePassword', () {
    test('devuelve Success cuando el cambio se aplica', () async {
      when(
        () =>
            datasource.updatePassword(newPassword: any(named: 'newPassword')),
      ).thenAnswer((_) async {});

      final Result<void> result = await repository.updatePassword(
        newPassword: 'nueva-clave',
      );

      expect(result, isA<Success<void>>());
      verify(
        () => datasource.updatePassword(newPassword: 'nueva-clave'),
      ).called(1);
    });

    test('sin sesión válida llega como Failure', () async {
      when(
        () =>
            datasource.updatePassword(newPassword: any(named: 'newPassword')),
      ).thenThrow(const UnauthorizedFailure());

      final Result<void> result = await repository.updatePassword(
        newPassword: 'nueva-clave',
      );

      expect(
        (result as FailureResult<void>).failure,
        isA<UnauthorizedFailure>(),
      );
    });
  });

  group('signOut', () {
    test('devuelve Success cuando la sesión se cierra', () async {
      when(datasource.signOut).thenAnswer((_) async {});

      expect(await repository.signOut(), isA<Success<void>>());
      verify(datasource.signOut).called(1);
    });

    test('un error inesperado no se filtra crudo al dominio', () async {
      when(datasource.signOut).thenThrow(Exception('boom'));

      final Result<void> result = await repository.signOut();

      // El detalle técnico va al log y el usuario ve un mensaje genérico.
      expect(
        (result as FailureResult<void>).failure,
        isA<UnexpectedFailure>(),
      );
    });
  });
}
