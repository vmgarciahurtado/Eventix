import 'package:eventix/features/payments/domain/entities/checkout_session.dart';
import 'package:eventix/features/payments/domain/entities/payment_verification.dart';
import 'package:eventix/features/payments/infrastructure/models/remote_checkout_session_model.dart';
import 'package:eventix/features/payments/infrastructure/models/remote_payment_verification_model.dart';

abstract final class PaymentMappers {
  static CheckoutSession toCheckoutSession(RemoteCheckoutSessionModel m) =>
      CheckoutSession(url: m.url, sessionId: m.sessionId);

  static PaymentVerification toPaymentVerification(
    RemotePaymentVerificationModel m,
  ) => PaymentVerification(paid: m.paid, reservationConfirmed: m.confirmed);
}
