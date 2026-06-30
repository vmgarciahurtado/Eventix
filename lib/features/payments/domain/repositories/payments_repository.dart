import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/payments/domain/entities/checkout_session.dart';

abstract interface class PaymentsRepository {
  /// Crea una sesión de pago para [quantity] cupos de [eventId]. Si
  /// [wantInvoice] es true, Stripe envía la factura al correo del usuario.
  Future<Result<CheckoutSession>> createCheckout({
    required String eventId,
    required int quantity,
    required bool wantInvoice,
  });

  /// Devuelve true si la sesión [sessionId] quedó pagada.
  Future<Result<bool>> verifyCheckout({required String sessionId});
}
