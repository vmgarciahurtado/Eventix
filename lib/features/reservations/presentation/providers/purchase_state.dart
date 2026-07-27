import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/features/payments/domain/entities/checkout_session.dart';
import 'package:eventix/features/reservations/domain/entities/reservation.dart';

/// Estados del flujo de compra: reservar → pagar → confirmar.
sealed class PurchaseState {
  const PurchaseState();
}

class PurchaseIdle extends PurchaseState {
  const PurchaseIdle();
}

/// Creando la reserva o el checkout, o verificando el pago.
class PurchaseWorking extends PurchaseState {
  const PurchaseWorking();
}

/// Reserva pendiente creada; falta que el usuario pague en el WebView.
class PurchaseAwaitingPayment extends PurchaseState {
  const PurchaseAwaitingPayment({
    required this.reservation,
    required this.session,
  });

  final Reservation reservation;
  final CheckoutSession session;
}

/// Reserva confirmada (gratuita, o pagada y verificada).
class PurchaseSuccess extends PurchaseState {
  const PurchaseSuccess({required this.reservation});

  final Reservation reservation;
}

/// El usuario cerró el checkout: la reserva pendiente se liberó.
class PurchaseCancelled extends PurchaseState {
  const PurchaseCancelled();
}

/// El checkout terminó sin cobro: la reserva pendiente se liberó.
class PurchaseNotPaid extends PurchaseState {
  const PurchaseNotPaid();
}

/// Pago recibido pero la reserva no pudo confirmarse (pending expirado y cupo
/// revendido). Caso excepcional que requiere soporte.
class PurchaseUnconfirmed extends PurchaseState {
  const PurchaseUnconfirmed();
}

class PurchaseFailed extends PurchaseState {
  const PurchaseFailed(this.failure);

  final Failure failure;
}
