import 'package:eventix/core/helpers/execute_repository_call.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/auth/domain/enums/otp_purpose.dart';
import 'package:eventix/features/auth/domain/repositories/auth_repository.dart';
import 'package:eventix/features/auth/infrastructure/datasources/auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._datasource);

  final AuthDatasource _datasource;

  @override
  Future<Result<void>> signIn({
    required String email,
    required String password,
  }) {
    return executeRepositoryCall(
      () => _datasource.signIn(email: email, password: password),
    );
  }

  @override
  Future<Result<void>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) {
    return executeRepositoryCall(
      () => _datasource.signUp(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      ),
    );
  }

  @override
  Future<Result<void>> verifyOtp({
    required String email,
    required String token,
    required OtpPurpose purpose,
  }) {
    return executeRepositoryCall(
      () => _datasource.verifyOtp(email: email, token: token, purpose: purpose),
    );
  }

  @override
  Future<Result<void>> resendOtp({
    required String email,
    required OtpPurpose purpose,
  }) {
    return executeRepositoryCall(
      () => _datasource.resendOtp(email: email, purpose: purpose),
    );
  }

  @override
  Future<Result<void>> sendPasswordReset({required String email}) {
    return executeRepositoryCall(
      () => _datasource.sendPasswordReset(email: email),
    );
  }

  @override
  Future<Result<void>> updatePassword({required String newPassword}) {
    return executeRepositoryCall(
      () => _datasource.updatePassword(newPassword: newPassword),
    );
  }

  @override
  Future<Result<void>> signOut() {
    return executeRepositoryCall(() => _datasource.signOut());
  }
}
