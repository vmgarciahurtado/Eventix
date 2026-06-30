import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/payments/domain/repositories/payments_repository.dart';

class VerifyCheckoutSession {
  const VerifyCheckoutSession(this._repository);

  final PaymentsRepository _repository;

  Future<Result<bool>> call({required String sessionId}) =>
      _repository.verifyCheckout(sessionId: sessionId);
}
