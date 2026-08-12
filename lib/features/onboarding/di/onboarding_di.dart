import 'package:eventix/features/onboarding/domain/usecases/complete_onboarding_use_case.dart';
import 'package:eventix/features/profile/di/profile_di.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Composition root de la feature onboarding.
final Provider<CompleteOnboardingUseCase> completeOnboardingProvider =
    Provider<CompleteOnboardingUseCase>(
      (Ref ref) =>
          CompleteOnboardingUseCase(ref.watch(profileRepositoryProvider)),
    );
