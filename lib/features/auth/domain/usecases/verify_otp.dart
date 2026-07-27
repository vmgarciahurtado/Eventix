import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/auth/domain/enums/otp_purpose.dart';
import 'package:eventix/features/auth/domain/repositories/auth_repository.dart';

class VerifyOtp {
  const VerifyOtp(this._repository);

  final AuthRepository _repository;

  Future<Result<void>> call({
    required String email,
    required String token,
    required OtpPurpose purpose,
  }) => _repository.verifyOtp(email: email, token: token, purpose: purpose);
}
