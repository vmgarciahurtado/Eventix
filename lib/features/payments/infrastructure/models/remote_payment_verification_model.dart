/// Payload de `stripe-verify-checkout`.
class RemotePaymentVerificationModel {
  const RemotePaymentVerificationModel({
    required this.paid,
    required this.confirmed,
  });

  final bool paid;
  final bool confirmed;
}
