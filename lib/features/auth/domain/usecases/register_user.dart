import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/auth/domain/repositories/auth_repository.dart';

class RegisterUser {
  const RegisterUser(this._repository);

  final AuthRepository _repository;

  Future<Result<void>> call({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) => _repository.register(
    email: email,
    password: password,
    firstName: firstName,
    lastName: lastName,
  );
}
