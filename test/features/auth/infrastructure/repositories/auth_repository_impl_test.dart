import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/auth/domain/entities/app_user.dart';
import 'package:eventix/features/auth/domain/entities/otp_purpose.dart';
import 'package:eventix/features/auth/infrastructure/datasources/auth_datasource.dart';
import 'package:eventix/features/auth/infrastructure/repositories/auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthDatasource extends Mock implements AuthDatasource {}

void main() {
  late _MockAuthDatasource datasource;
  late AuthRepositoryImpl repository;

  setUpAll(() => registerFallbackValue(OtpPurpose.signup));

  setUp(() {
    datasource = _MockAuthDatasource();
    repository = AuthRepositoryImpl(datasource);
  });

  group('signIn', () {
    test('returns Success when the datasource completes', () async {
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
    });

    test('returns FailureResult when datasource throws', () async {
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

  group('currentProfile', () {
    test('maps the profile row into an AppUser', () async {
      when(datasource.fetchCurrentProfile).thenAnswer(
        (_) async => <String, dynamic>{
          'id': 'uuid-1',
          'email': 'a@b.com',
          'first_name': 'Ana',
          'last_name': 'Gómez',
          'onboarding_completed': true,
        },
      );

      final Result<AppUser?> result = await repository.currentProfile();

      expect(result, isA<Success<AppUser?>>());
      final AppUser? user = (result as Success<AppUser?>).data;
      expect(user, isNotNull);
      expect(user!.id, 'uuid-1');
      expect(user.fullName, 'Ana Gómez');
      expect(user.onboardingCompleted, isTrue);
    });

    test('returns null data when there is no profile row', () async {
      when(datasource.fetchCurrentProfile).thenAnswer((_) async => null);

      final Result<AppUser?> result = await repository.currentProfile();

      expect(result, isA<Success<AppUser?>>());
      expect((result as Success<AppUser?>).data, isNull);
    });
  });

  group('verifyOtp', () {
    test('delegates to the datasource with the given purpose', () async {
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
  });
}
