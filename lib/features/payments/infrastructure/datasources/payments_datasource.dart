import 'package:eventix/features/payments/domain/entities/checkout_session.dart';

abstract interface class PaymentsDatasource {
  Future<CheckoutSession> createCheckout({
    required String eventId,
    required int quantity,
    required bool wantInvoice,
  });

  Future<bool> verifyCheckout({required String sessionId});
}
