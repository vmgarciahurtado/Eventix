/// Payload de `stripe-verify-checkout`.
class RemotePaymentVerificationModel {
  const RemotePaymentVerificationModel({
    required this.paid,
    required this.confirmed,
  });

  factory RemotePaymentVerificationModel.fromJson(Map<String, dynamic> json) =>
      RemotePaymentVerificationModel(
        paid: json['paid'] == true,
        confirmed: json['confirmed'] == true,
      );

  final bool paid;
  final bool confirmed;
}
