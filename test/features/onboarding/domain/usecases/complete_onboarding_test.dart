import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/onboarding/domain/usecases/complete_onboarding.dart';
import 'package:eventix/features/profile/domain/repositories/profile_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late _MockProfileRepository repository;

  setUp(() => repository = _MockProfileRepository());

  test('marca el onboarding como completado', () async {
    when(
      repository.completeOnboarding,
    ).thenAnswer((_) async => const Success<void>(null));

    expect(
      await CompleteOnboarding(repository).call(),
      isA<Success<void>>(),
    );
    verify(repository.completeOnboarding).called(1);
  });

  test('si el guardado falla lo reporta', () async {
    when(
      repository.completeOnboarding,
    ).thenAnswer((_) async => const FailureResult<void>(ServerFailure()));

    // Tragarse el fallo haría reaparecer el onboarding sin explicación.
    expect(
      await CompleteOnboarding(repository).call(),
      isA<FailureResult<void>>(),
    );
  });
}
