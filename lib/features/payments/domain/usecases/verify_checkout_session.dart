import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/payments/domain/entities/payment_verification.dart';
import 'package:eventix/features/payments/domain/repositories/payments_repository.dart';

class VerifyCheckoutSession {
  const VerifyCheckoutSession(this._repository);

  final PaymentsRepository _repository;

  Future<Result<PaymentVerification>> call({required String sessionId}) =>
      _repository.verifyCheckout(sessionId: sessionId);
}
