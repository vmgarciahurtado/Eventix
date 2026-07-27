import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/payments/domain/entities/payment_verification.dart';
import 'package:eventix/features/payments/domain/usecases/verify_checkout_session.dart';
import 'package:eventix/features/reservations/domain/enums/payment_completion.dart';

/// Verifica el pago al volver del checkout y traduce el resultado al
/// vocabulario del flujo de compra ([PaymentCompletion]). El servidor confirma
/// la reserva server-side; aquí solo se interpreta lo que devolvió.
class CompletePayment {
  const CompletePayment(this._verifyCheckout);

  final VerifyCheckoutSession _verifyCheckout;

  Future<Result<PaymentCompletion>> call({required String sessionId}) async {
    final Result<PaymentVerification> verified = await _verifyCheckout(
      sessionId: sessionId,
    );
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
}
