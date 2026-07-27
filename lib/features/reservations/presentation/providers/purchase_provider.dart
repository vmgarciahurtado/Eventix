import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/payments/domain/enums/checkout_result.dart';
import 'package:eventix/features/reservations/di/reservations_di.dart';
import 'package:eventix/features/reservations/domain/entities/purchase_outcome.dart';
import 'package:eventix/features/reservations/domain/enums/payment_completion.dart';
import 'package:eventix/features/reservations/presentation/providers/purchase_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estados del flujo de compra. La página solo reacciona a los
/// estados: abrir el WebView, navegar, avisar.
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
        .read(startPurchaseProvider)
        .call(
          eventId: eventId,
          unitPrice: unitPrice,
          quantity: quantity,
          wantInvoice: wantInvoice,
        );

    state = switch (result) {
      FailureResult<PurchaseOutcome>(:final Failure failure) => PurchaseFailed(
        failure,
      ),
      Success<PurchaseOutcome>(data: final PurchaseCompleted done) =>
        PurchaseSuccess(reservation: done.reservation),
      Success<PurchaseOutcome>(data: final PurchasePaymentRequired pending) =>
        PurchaseAwaitingPayment(
          reservation: pending.reservation,
          session: pending.session,
        ),
    };
  }

  /// Procesa el resultado del WebView de checkout.
  Future<void> finishPayment(CheckoutResult result) async {
    final PurchaseState current = state;
    if (current is! PurchaseAwaitingPayment) return;
    state = const PurchaseWorking();

    if (result == CheckoutResult.cancel) {
      await _releasePending(current.reservation.id);
      state = const PurchaseCancelled();
      return;
    }

    final Result<PaymentCompletion> completion = await ref
        .read(completePaymentProvider)
        .call(sessionId: current.session.sessionId);

    switch (completion) {
      case FailureResult<PaymentCompletion>(:final Failure failure):
        state = PurchaseFailed(failure);
      case Success<PaymentCompletion>(data: PaymentCompletion.confirmed):
        state = PurchaseSuccess(reservation: current.reservation);
      case Success<PaymentCompletion>(data: PaymentCompletion.notPaid):
        await _releasePending(current.reservation.id);
        state = const PurchaseNotPaid();
      case Success<PaymentCompletion>(
        data: PaymentCompletion.paidButNotConfirmed,
      ):
        state = const PurchaseUnconfirmed();
    }
  }

  void reset() => state = const PurchaseIdle();

  /// Si el borrado falla, el pending expira solo en 15 min.
  Future<void> _releasePending(String reservationId) =>
      ref.read(cancelPendingReservationProvider).call(id: reservationId);
}

final NotifierProvider<PurchaseNotifier, PurchaseState> purchaseProvider =
    NotifierProvider.autoDispose<PurchaseNotifier, PurchaseState>(
      PurchaseNotifier.new,
    );
