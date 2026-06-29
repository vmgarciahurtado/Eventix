import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/auth/domain/repositories/auth_repository.dart';

class UpdatePassword {
  const UpdatePassword(this._repository);

  final AuthRepository _repository;

  Future<Result<void>> call({required String newPassword}) =>
      _repository.updatePassword(newPassword: newPassword);
}
