import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/profile/domain/entities/app_user.dart';
import 'package:eventix/features/profile/domain/repositories/profile_repository.dart';

class GetCurrentProfile {
  const GetCurrentProfile(this._repository);

  final ProfileRepository _repository;

  Future<Result<AppUser?>> call() => _repository.currentProfile();
}
