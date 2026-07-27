import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/payments/domain/entities/checkout_session.dart';
import 'package:eventix/features/payments/domain/usecases/create_checkout_session.dart';
import 'package:eventix/features/reservations/domain/entities/purchase_outcome.dart';
import 'package:eventix/features/reservations/domain/entities/reservation.dart';
import 'package:eventix/features/reservations/domain/enums/reservation_status.dart';
import 'package:eventix/features/reservations/domain/usecases/cancel_pending_reservation.dart';
import 'package:eventix/features/reservations/domain/usecases/create_reservation.dart';

/// Si el checkout no puede crearse, cancela la reserva pendiente para no
/// dejar cupo retenido. Los eventos gratuitos nacen `confirmed`: el backend
/// valida que lo sean antes de aceptar ese insert.
class StartPurchase {
  const StartPurchase({
    required CreateReservation createReservation,
    required CancelPendingReservation cancelPendingReservation,
    required CreateCheckoutSession createCheckout,
  }) : _createReservation = createReservation,
       _cancelPendingReservation = cancelPendingReservation,
       _createCheckout = createCheckout;

  final CreateReservation _createReservation;
  final CancelPendingReservation _cancelPendingReservation;
  final CreateCheckoutSession _createCheckout;

  /// Tope de cupos por compra (regla de negocio, no de UI).
  static const int maxPerPurchase = 10;

  Future<Result<PurchaseOutcome>> call({
    required String eventId,
    required double unitPrice,
    required int quantity,
    required bool wantInvoice,
  }) async {
    final bool isFree = unitPrice * quantity <= 0;
    final Result<Reservation> created = await _createReservation(
      eventId: eventId,
      quantity: quantity,
      initialStatus: isFree
          ? ReservationStatus.confirmed
          : ReservationStatus.pending,
    );

    switch (created) {
      case FailureResult<Reservation>(failure: final Failure failure):
        return FailureResult<PurchaseOutcome>(failure);
      case Success<Reservation>(data: final Reservation reservation):
        if (isFree) {
          return Success<PurchaseOutcome>(
            PurchaseCompleted(reservation: reservation),
          );
        }
        final Result<CheckoutSession> checkout = await _createCheckout(
          reservationId: reservation.id,
          wantInvoice: wantInvoice,
        );
        switch (checkout) {
          case FailureResult<CheckoutSession>(failure: final Failure failure):
            await _cancelPendingReservation(id: reservation.id);
            return FailureResult<PurchaseOutcome>(failure);
          case Success<CheckoutSession>(data: final CheckoutSession session):
            return Success<PurchaseOutcome>(
              PurchasePaymentRequired(
                reservation: reservation,
                session: session,
              ),
            );
        }
    }
  }
}
