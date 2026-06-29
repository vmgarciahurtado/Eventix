import 'dart:async';

import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/example/di/example_di.dart';
import 'package:eventix/features/example/domain/entities/example.dart';
import 'package:eventix/features/example/domain/usecases/get_examples.dart';
import 'package:eventix/features/example/presentation/providers/examples_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/src/framework.dart';

class MockGetExamples extends Mock implements GetExamples {}

void main() {
  late MockGetExamples mockGetExamples;

  setUpAll(() {
    registerFallbackValue(<Example>[]);
  });

  setUp(() {
    mockGetExamples = MockGetExamples();
  });

  ProviderContainer makeContainer() {
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        getExamplesProvider.overrideWithValue(mockGetExamples),
      ],
      // Disable Riverpod 3.x automatic retry. By default, build() errors
      // trigger exponential-backoff retries (200ms–6400ms × 10 attempts),
      // which keeps the provider in AsyncLoading for the entire test timeout.
      retry: (_, __) => null,
    );
    // A stored subscription keeps the auto-dispose provider alive for the
    // entire test. Without the reference, Dart GC can collect it before
    // build() completes, causing a StateError on the future.
    final ProviderSubscription<AsyncValue<List<Example>>> sub = container
        .listen<AsyncValue<List<Example>>>(
          examplesProvider,
          (_, __) {},
        );
    addTearDown(sub.close);
    addTearDown(container.dispose);
    return container;
  }

  // Waits until examplesProvider leaves AsyncLoading. In Riverpod 3.x,
  // provider.future only resolves for AsyncData — it never rejects for
  // AsyncError. This helper works for both outcomes.
  Future<AsyncValue<List<Example>>> awaitSettled(
    ProviderContainer container,
  ) async {
    final Completer<AsyncValue<List<Example>>> done =
        Completer<AsyncValue<List<Example>>>();
    final ProviderSubscription<AsyncValue<List<Example>>> sub = container
        .listen<AsyncValue<List<Example>>>(
          examplesProvider,
          (_, AsyncValue<List<Example>> next) {
            if (!next.isLoading && !done.isCompleted) {
              done.complete(next);
            }
          },
          // fireImmediately handles the case where the provider already settled
          // (e.g. on the second call after invalidate).
          fireImmediately: true,
        );
    try {
      return await done.future;
    } finally {
      sub.close();
    }
  }

  group('examplesProvider', () {
    test(
      'given the use case returns examples '
      'when the provider is read '
      'then state contains the loaded examples',
      () async {
        when(
          () => mockGetExamples.call(),
        ).thenAnswer(
          (_) async => Success<List<Example>>(<Example>[_tExample()]),
        );

        final ProviderContainer container = makeContainer();
        final AsyncValue<List<Example>> state = await awaitSettled(container);

        expect(state.value?.length, 1);
        expect(state.hasError, isFalse);
      },
    );

    test(
      'given the use case returns a failure '
      'when the provider is read '
      'then state has error with the original Failure',
      () async {
        when(
          () => mockGetExamples.call(),
        ).thenAnswer(
          (_) async => const FailureResult<List<Example>>(ConnectionFailure()),
        );

        final ProviderContainer container = makeContainer();
        final AsyncValue<List<Example>> state = await awaitSettled(container);

        expect(state.hasError, isTrue);
        expect(state.error, isA<ConnectionFailure>());
      },
    );

    test(
      'given the provider is in an error state '
      'when invalidated and the use case now succeeds '
      'then state is refreshed with examples',
      () async {
        when(
          () => mockGetExamples.call(),
        ).thenAnswer(
          (_) async => const FailureResult<List<Example>>(ConnectionFailure()),
        );

        final ProviderContainer container = makeContainer();
        final AsyncValue<List<Example>> errorState = await awaitSettled(
          container,
        );
        expect(errorState.hasError, isTrue);

        when(
          () => mockGetExamples.call(),
        ).thenAnswer(
          (_) async => Success<List<Example>>(<Example>[_tExample()]),
        );
        container.invalidate(examplesProvider);
        final AsyncValue<List<Example>> dataState = await awaitSettled(
          container,
        );

        expect(dataState.value?.length, 1);
        expect(dataState.hasError, isFalse);
      },
    );
  });
}

Example _tExample() => const Example(
  id: 1,
  name: 'Test Example',
  description: 'Test description',
);
