import 'package:eventix/features/payments/domain/entities/checkout_session.dart';
import 'package:eventix/features/payments/domain/entities/payment_verification.dart';

abstract interface class PaymentsDatasource {
  /// Crea la sesión de pago para una reserva pendiente ya creada. Cantidad y
  /// precio los resuelve el servidor a partir de la reserva.
  Future<CheckoutSession> createCheckout({
    required String reservationId,
    required bool wantInvoice,
  });

  Future<PaymentVerification> verifyCheckout({required String sessionId});
}
