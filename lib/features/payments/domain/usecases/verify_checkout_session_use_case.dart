import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/payments/domain/entities/payment_verification.dart';
import 'package:eventix/features/payments/domain/repositories/payments_repository.dart';

class VerifyCheckoutSessionUseCase {
  const VerifyCheckoutSessionUseCase(this._repository);

  final PaymentsRepository _repository;

  Future<Result<PaymentVerification>> call({required String sessionId}) {
    return _repository.verifyCheckout(sessionId: sessionId);
  }
}
