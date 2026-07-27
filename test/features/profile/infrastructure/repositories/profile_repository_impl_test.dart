import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/profile/domain/entities/app_user.dart';
import 'package:eventix/features/profile/infrastructure/datasources/profile_datasource.dart';
import 'package:eventix/features/profile/infrastructure/models/remote_profile_model.dart';
import 'package:eventix/features/profile/infrastructure/repositories/profile_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockProfileDatasource extends Mock implements ProfileDatasource {}

void main() {
  late _MockProfileDatasource datasource;
  late ProfileRepositoryImpl repository;

  setUp(() {
    datasource = _MockProfileDatasource();
    repository = ProfileRepositoryImpl(datasource);
  });

  group('currentProfile', () {
    test('maps the profile row into an AppUser', () async {
      when(datasource.fetchCurrentProfile).thenAnswer(
        (_) async => const RemoteProfileModel(
          id: 'uuid-1',
          email: 'a@b.com',
          firstName: 'Ana',
          lastName: 'Gómez',
          onboardingCompleted: true,
        ),
      );

      final Result<AppUser?> result = await repository.currentProfile();

      expect(result, isA<Success<AppUser?>>());
      final AppUser? user = (result as Success<AppUser?>).data;
      expect(user, isNotNull);
      expect(user!.id, 'uuid-1');
      expect(user.firstName, 'Ana');
      expect(user.lastName, 'Gómez');
      expect(user.onboardingCompleted, isTrue);
    });

    test('returns null data when there is no profile row', () async {
      when(datasource.fetchCurrentProfile).thenAnswer((_) async => null);

      final Result<AppUser?> result = await repository.currentProfile();

      expect(result, isA<Success<AppUser?>>());
      expect((result as Success<AppUser?>).data, isNull);
    });

    test('propagates UnauthorizedFailure when there is no session', () async {
      when(
        datasource.fetchCurrentProfile,
      ).thenThrow(const UnauthorizedFailure());

      final Result<AppUser?> result = await repository.currentProfile();

      expect(result, isA<FailureResult<AppUser?>>());
      expect(
        (result as FailureResult<AppUser?>).failure,
        isA<UnauthorizedFailure>(),
      );
    });
  });

  group('completeOnboarding', () {
    test('delegates to the datasource', () async {
      when(datasource.completeOnboarding).thenAnswer((_) async {});

      final Result<void> result = await repository.completeOnboarding();

      expect(result, isA<Success<void>>());
      verify(datasource.completeOnboarding).called(1);
    });
  });
}
