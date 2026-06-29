import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/auth/domain/repositories/auth_repository.dart';

class SignIn {
  const SignIn(this._repository);

  final AuthRepository _repository;

  Future<Result<void>> call({
    required String email,
    required String password,
  }) => _repository.signIn(email: email, password: password);
}
