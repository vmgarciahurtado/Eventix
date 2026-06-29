import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/auth/domain/entities/app_user.dart';
import 'package:eventix/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentProfile {
  const GetCurrentProfile(this._repository);

  final AuthRepository _repository;

  Future<Result<AppUser?>> call() => _repository.currentProfile();
}
