import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/onboarding/di/onboarding_di.dart';
import 'package:eventix/features/onboarding/domain/usecases/complete_onboarding.dart';
import 'package:eventix/features/onboarding/presentation/providers/finish_onboarding_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCompleteOnboarding extends Mock implements CompleteOnboarding {}

void main() {
  late _MockCompleteOnboarding completeOnboarding;
  late ProviderContainer container;

  setUp(() {
    completeOnboarding = _MockCompleteOnboarding();
    container = ProviderContainer(
      overrides: <Override>[
        completeOnboardingProvider.overrideWithValue(completeOnboarding),
      ],
    );
    addTearDown(container.dispose);
  });

  void mockComplete(Result<void> result) =>
      when(completeOnboarding.call).thenAnswer((_) async => result);

  Future<void> finish() =>
      container.read(finishOnboardingProvider.notifier).finish();

  test('expone AsyncData al guardar con Success', () async {
    mockComplete(const Success<void>(null));

    await finish();

    expect(container.read(finishOnboardingProvider), isA<AsyncData<void>>());
  });

  test('expone AsyncError con el Failure cuando el guardado falla', () async {
    mockComplete(const FailureResult<void>(ConnectionFailure()));

    await finish();

    final AsyncValue<void> state = container.read(finishOnboardingProvider);
    expect(state, isA<AsyncError<void>>());
    expect((state as AsyncError<void>).error, isA<ConnectionFailure>());
  });

  test('ignora un segundo toque mientras el primero está en curso', () async {
    mockComplete(const Success<void>(null));

    await Future.wait<void>(<Future<void>>[finish(), finish()]);

    verify(completeOnboarding.call).called(1);
  });
}
