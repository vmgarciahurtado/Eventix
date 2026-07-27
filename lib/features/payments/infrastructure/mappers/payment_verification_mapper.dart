import 'package:eventix/features/payments/domain/entities/payment_verification.dart';
import 'package:eventix/features/payments/infrastructure/models/remote_payment_verification_model.dart';

abstract final class PaymentVerificationMapper {
  static PaymentVerification toEntity(RemotePaymentVerificationModel m) =>
      PaymentVerification(paid: m.paid, reservationConfirmed: m.confirmed);
}
