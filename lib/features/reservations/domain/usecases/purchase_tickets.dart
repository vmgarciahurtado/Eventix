import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/payments/domain/entities/checkout_session.dart';
import 'package:eventix/features/payments/domain/entities/payment_verification.dart';
import 'package:eventix/features/payments/domain/repositories/payments_repository.dart';
import 'package:eventix/features/reservations/domain/entities/purchase_outcome.dart';
import 'package:eventix/features/reservations/domain/entities/reservation.dart';
import 'package:eventix/features/reservations/domain/entities/reservation_status.dart';
import 'package:eventix/features/reservations/domain/repositories/reservations_repository.dart';

/// Orquesta la compra de cupos: reservar primero (reteniendo cupo), pagar
/// después, confirmar server-side al verificar el pago.
///
/// Flujo pago:  pending → checkout → (usuario paga) → verify → confirmed.
/// Flujo gratis: confirmed directo (el backend valida que el evento sea
/// gratuito antes de aceptar un insert confirmado).
class PurchaseTickets {
  const PurchaseTickets({
    required ReservationsRepository reservations,
    required PaymentsRepository payments,
  }) : _reservations = reservations,
       _payments = payments;

  final ReservationsRepository _reservations;
  final PaymentsRepository _payments;

  /// Tope de cupos por compra (regla de negocio, no de UI).
  static const int maxPerPurchase = 10;

  /// Crea la reserva y, si el evento es pago, la sesión de checkout.
  /// Si el checkout no puede crearse, la reserva pendiente se cancela para
  /// no retener cupo.
  Future<Result<PurchaseOutcome>> start({
    required String eventId,
    required double unitPrice,
    required int quantity,
    required bool wantInvoice,
  }) async {
    final bool isFree = unitPrice * quantity <= 0;
    final Result<Reservation> created = await _reservations.createReservation(
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
        final Result<CheckoutSession> checkout = await _payments
            .createCheckout(
              reservationId: reservation.id,
              wantInvoice: wantInvoice,
            );
        switch (checkout) {
          case FailureResult<CheckoutSession>(failure: final Failure failure):
            await _reservations.cancelPendingReservation(id: reservation.id);
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

  /// Verifica el pago al volver del checkout. El servidor confirma la
  /// reserva; aquí solo se interpreta el resultado.
  Future<Result<PaymentCompletion>> completePayment({
    required String sessionId,
  }) async {
    final Result<PaymentVerification> verified = await _payments
        .verifyCheckout(sessionId: sessionId);
    return switch (verified) {
      FailureResult<PaymentVerification>(failure: final Failure failure) =>
        FailureResult<PaymentCompletion>(failure),
      Success<PaymentVerification>(data: final PaymentVerification v) =>
        Success<PaymentCompletion>(
          !v.paid
              ? PaymentCompletion.notPaid
              : v.reservationConfirmed
              ? PaymentCompletion.confirmed
              : PaymentCompletion.paidButNotConfirmed,
        ),
    };
  }

  /// Cancela la reserva pendiente cuando el usuario abandona el pago,
  /// liberando el cupo retenido.
  Future<Result<void>> abandonPayment({required String reservationId}) =>
      _reservations.cancelPendingReservation(id: reservationId);
}
