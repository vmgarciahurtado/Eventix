import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/auth/domain/repositories/auth_repository.dart';

class SendPasswordReset {
  const SendPasswordReset(this._repository);

  final AuthRepository _repository;

  Future<Result<void>> call({required String email}) =>
      _repository.sendPasswordReset(email: email);
}
