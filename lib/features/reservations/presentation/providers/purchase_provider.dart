import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/payments/domain/entities/checkout_result.dart';
import 'package:eventix/features/payments/domain/entities/checkout_session.dart';
import 'package:eventix/features/reservations/di/reservations_di.dart';
import 'package:eventix/features/reservations/domain/entities/purchase_outcome.dart';
import 'package:eventix/features/reservations/domain/entities/reservation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estados explícitos del flujo de compra (reservar → pagar → confirmar).
sealed class PurchaseState {
  const PurchaseState();
}

class PurchaseIdle extends PurchaseState {
  const PurchaseIdle();
}

/// Hay una operación en curso (creando reserva/checkout o verificando pago).
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

/// Reserva confirmada (gratuita o pagada y verificada).
class PurchaseSuccess extends PurchaseState {
  const PurchaseSuccess({required this.reservation});

  final Reservation reservation;
}

/// El usuario canceló el pago: la reserva pendiente se liberó.
class PurchaseCancelled extends PurchaseState {
  const PurchaseCancelled();
}

/// Pago recibido pero la reserva no pudo confirmarse (pending expirado y
/// cupo revendido). Caso excepcional que requiere soporte.
class PurchaseUnconfirmed extends PurchaseState {
  const PurchaseUnconfirmed();
}

class PurchaseFailed extends PurchaseState {
  const PurchaseFailed(this.failure);

  final Failure failure;
}

/// Orquesta la compra desde la UI delegando la lógica a [PurchaseTickets].
/// La página solo reacciona a los estados (abrir WebView, navegar, snack).
class PurchaseNotifier extends Notifier<PurchaseState> {
  @override
  PurchaseState build() => const PurchaseIdle();

  Future<void> start({
    required String eventId,
    required double unitPrice,
    required int quantity,
    required bool wantInvoice,
  }) async {
    if (state is PurchaseWorking || state is PurchaseAwaitingPayment) return;
    state = const PurchaseWorking();

    final Result<PurchaseOutcome> result = await ref
        .read(purchaseTicketsProvider)
        .start(
          eventId: eventId,
          unitPrice: unitPrice,
          quantity: quantity,
          wantInvoice: wantInvoice,
        );

    switch (result) {
      case FailureResult<PurchaseOutcome>(failure: final Failure failure):
        state = PurchaseFailed(failure);
      case Success<PurchaseOutcome>(
        data: final PurchaseCompleted completed,
      ):
        state = PurchaseSuccess(reservation: completed.reservation);
      case Success<PurchaseOutcome>(
        data: final PurchasePaymentRequired pending,
      ):
        state = PurchaseAwaitingPayment(
          reservation: pending.reservation,
          session: pending.session,
        );
    }
  }

  /// Procesa el resultado del WebView de checkout.
  Future<void> finishPayment(CheckoutResult result) async {
    final PurchaseState current = state;
    if (current is! PurchaseAwaitingPayment) return;
    state = const PurchaseWorking();

    if (result == CheckoutResult.cancel) {
      // Best effort: si el borrado falla, el pending expira solo en 15 min.
      await ref
          .read(purchaseTicketsProvider)
          .abandonPayment(reservationId: current.reservation.id);
      state = const PurchaseCancelled();
      return;
    }

    final Result<PaymentCompletion> completion = await ref
        .read(purchaseTicketsProvider)
        .completePayment(sessionId: current.session.sessionId);

    switch (completion) {
      case FailureResult<PaymentCompletion>(failure: final Failure failure):
        state = PurchaseFailed(failure);
      case Success<PaymentCompletion>(data: PaymentCompletion.confirmed):
        state = PurchaseSuccess(reservation: current.reservation);
      case Success<PaymentCompletion>(data: PaymentCompletion.notPaid):
        await ref
            .read(purchaseTicketsProvider)
            .abandonPayment(reservationId: current.reservation.id);
        state = const PurchaseFailed(
          ValidationFailure('El pago no se completó. Intenta de nuevo.'),
        );
      case Success<PaymentCompletion>(
        data: PaymentCompletion.paidButNotConfirmed,
      ):
        state = const PurchaseUnconfirmed();
    }
  }

  void reset() => state = const PurchaseIdle();
}

final NotifierProvider<PurchaseNotifier, PurchaseState> purchaseProvider =
    NotifierProvider.autoDispose<PurchaseNotifier, PurchaseState>(
      PurchaseNotifier.new,
    );
