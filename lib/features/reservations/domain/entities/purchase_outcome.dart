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
/// checkout lista para pagar.
class PurchasePaymentRequired extends PurchaseOutcome {
  const PurchasePaymentRequired({
    required this.reservation,
    required this.session,
  });

  final Reservation reservation;
  final CheckoutSession session;
}
