import 'dart:async';

import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/onboarding/di/onboarding_di.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FinishOnboardingNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> finish() async {
    if (state.isLoading) return;
    state = const AsyncLoading<void>();

    final Result<void> result = await ref
        .read(completeOnboardingProvider)
        .call();
    if (!ref.mounted) return;

    state = switch (result) {
      Success<void>() => const AsyncData<void>(null),
      FailureResult<void>(:final Failure failure) => AsyncError<void>(
        failure,
        StackTrace.current,
      ),
    };
  }
}

final AsyncNotifierProvider<FinishOnboardingNotifier, void>
finishOnboardingProvider =
    AsyncNotifierProvider<FinishOnboardingNotifier, void>(
      FinishOnboardingNotifier.new,
    );
