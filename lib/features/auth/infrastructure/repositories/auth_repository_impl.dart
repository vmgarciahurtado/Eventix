import 'package:eventix/core/helpers/execute_repository_call.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/auth/domain/entities/app_user.dart';
import 'package:eventix/features/auth/domain/entities/otp_purpose.dart';
import 'package:eventix/features/auth/domain/repositories/auth_repository.dart';
import 'package:eventix/features/auth/infrastructure/datasources/auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._datasource);

  final AuthDatasource _datasource;

  @override
  Future<Result<void>> signIn({
    required String email,
    required String password,
  }) => executeRepositoryCall(
    () => _datasource.signIn(email: email, password: password),
  );

  @override
  Future<Result<void>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) => executeRepositoryCall(
    () => _datasource.signUp(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    ),
  );

  @override
  Future<Result<void>> verifyOtp({
    required String email,
    required String token,
    required OtpPurpose purpose,
  }) => executeRepositoryCall(
    () => _datasource.verifyOtp(email: email, token: token, purpose: purpose),
  );

  @override
  Future<Result<void>> resendOtp({
    required String email,
    required OtpPurpose purpose,
  }) => executeRepositoryCall(
    () => _datasource.resendOtp(email: email, purpose: purpose),
  );

  @override
  Future<Result<void>> sendPasswordReset({required String email}) =>
      executeRepositoryCall(
        () => _datasource.sendPasswordReset(email: email),
      );

  @override
  Future<Result<void>> updatePassword({required String newPassword}) =>
      executeRepositoryCall(
        () => _datasource.updatePassword(newPassword: newPassword),
      );

  @override
  Future<Result<void>> signOut() =>
      executeRepositoryCall(() => _datasource.signOut());

  @override
  Future<Result<AppUser?>> currentProfile() => executeRepositoryCall(() async {
    final Map<String, dynamic>? row = await _datasource.fetchCurrentProfile();
    if (row == null) return null;
    return AppUser(
      id: row['id'] as String,
      email: (row['email'] as String?) ?? '',
      firstName: (row['first_name'] as String?) ?? '',
      lastName: (row['last_name'] as String?) ?? '',
      onboardingCompleted: (row['onboarding_completed'] as bool?) ?? false,
    );
  });

  @override
  Future<Result<void>> completeOnboarding() =>
      executeRepositoryCall(() => _datasource.completeOnboarding());
}
