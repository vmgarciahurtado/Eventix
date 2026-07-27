import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/auth/domain/enums/otp_purpose.dart';
import 'package:eventix/features/auth/domain/repositories/auth_repository.dart';

class ResendOtp {
  const ResendOtp(this._repository);

  final AuthRepository _repository;

  Future<Result<void>> call({
    required String email,
    required OtpPurpose purpose,
  }) => _repository.resendOtp(email: email, purpose: purpose);
}
