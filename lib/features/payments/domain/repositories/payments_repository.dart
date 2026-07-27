import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/payments/domain/entities/checkout_session.dart';
import 'package:eventix/features/payments/domain/entities/payment_verification.dart';

abstract interface class PaymentsRepository {
  /// Crea una sesión de pago para la reserva pendiente [reservationId].
  /// Cantidad y precio son autoritativos del servidor. Si [wantInvoice] es
  /// true, la pasarela envía la factura al correo del usuario.
  Future<Result<CheckoutSession>> createCheckout({
    required String reservationId,
    required bool wantInvoice,
  });

  /// Verifica el pago de [sessionId]; si está pagado, el servidor confirma
  /// la reserva asociada.
  Future<Result<PaymentVerification>> verifyCheckout({
    required String sessionId,
  });
}
