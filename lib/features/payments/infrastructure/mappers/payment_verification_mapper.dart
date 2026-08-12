import 'package:eventix/features/payments/domain/entities/payment_verification.dart';
import 'package:eventix/features/payments/infrastructure/models/remote_payment_verification_model.dart';

abstract final class PaymentVerificationMapper {
  static RemotePaymentVerificationModel fromJson(Map<String, dynamic> json) {
    return RemotePaymentVerificationModel(
      paid: json['paid'] == true,
      confirmed: json['confirmed'] == true,
    );
  }

  static PaymentVerification toEntity(RemotePaymentVerificationModel m) {
    return PaymentVerification(paid: m.paid, reservationConfirmed: m.confirmed);
  }
}
