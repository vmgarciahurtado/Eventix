import 'package:eventix/features/onboarding/domain/usecases/complete_onboarding.dart';
import 'package:eventix/features/profile/di/profile_di.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Composition root de la feature onboarding.
final Provider<CompleteOnboarding> completeOnboardingProvider =
    Provider<CompleteOnboarding>(
      (Ref ref) => CompleteOnboarding(ref.watch(profileRepositoryProvider)),
    );
