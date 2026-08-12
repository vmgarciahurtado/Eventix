import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/payments/domain/entities/checkout_session.dart';
import 'package:eventix/features/payments/domain/repositories/payments_repository.dart';

class CreateCheckoutSessionUseCase {
  const CreateCheckoutSessionUseCase(this._repository);

  final PaymentsRepository _repository;

  Future<Result<CheckoutSession>> call({
    required String reservationId,
    required bool wantInvoice,
  }) {
    return _repository.createCheckout(
      reservationId: reservationId,
      wantInvoice: wantInvoice,
    );
  }
}
