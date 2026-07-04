import 'package:eventix/features/payments/domain/entities/checkout_session.dart';
import 'package:eventix/features/reservations/domain/entities/reservation.dart';

/// Resultado de iniciar una compra de cupos.
sealed class PurchaseOutcome {
  const PurchaseOutcome();
}

/// Evento gratuito: la reserva quedó confirmada de inmediato.
class PurchaseCompleted extends PurchaseOutcome {
  const PurchaseCompleted({required this.reservation});

  final Reservation reservation;
}

/// Evento pago: hay una reserva pendiente reteniendo cupo y una sesión de
/// Stripe lista para pagar.
class PurchasePaymentRequired extends PurchaseOutcome {
  const PurchasePaymentRequired({
    required this.reservation,
    required this.session,
  });

  final Reservation reservation;
  final CheckoutSession session;
}

/// Resultado de verificar el pago al volver del checkout.
enum PaymentCompletion {
  /// Pago verificado y reserva confirmada por el servidor.
  confirmed,

  /// Stripe no registró el pago (abandonó o falló el cobro).
  notPaid,

  /// Pago registrado pero la reserva no pudo confirmarse (p. ej. el pending
  /// expiró y el cupo se revendió). Requiere intervención/soporte.
  paidButNotConfirmed,
}
