import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/auth/domain/enums/post_auth_destination.dart';
import 'package:eventix/features/profile/domain/entities/app_user.dart';
import 'package:eventix/features/profile/domain/repositories/profile_repository.dart';

/// Sin sesión va al login; con sesión, a Home o al onboarding según lo haya
/// completado.
class ResolvePostAuthDestinationUseCase {
  const ResolvePostAuthDestinationUseCase(this._repository);

  final ProfileRepository _repository;

  Future<PostAuthDestination> call() async {
    final Result<AppUser?> profile = await _repository.currentProfile();
    return switch (profile) {
      Success<AppUser?>(data: final AppUser? user) =>
        (user?.onboardingCompleted ?? true)
            ? PostAuthDestination.home
            : PostAuthDestination.onboarding,
      FailureResult<AppUser?>(failure: UnauthorizedFailure()) =>
        PostAuthDestination.login,
      FailureResult<AppUser?>() => PostAuthDestination.home,
    };
  }
}
