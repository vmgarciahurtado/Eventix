import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/profile/domain/repositories/profile_repository.dart';

class CompleteOnboarding {
  const CompleteOnboarding(this._repository);

  final ProfileRepository _repository;

  Future<Result<void>> call() => _repository.completeOnboarding();
}
