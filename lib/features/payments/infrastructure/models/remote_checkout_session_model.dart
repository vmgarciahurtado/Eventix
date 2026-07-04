/// Payload de `stripe-create-checkout`.
class RemoteCheckoutSessionModel {
  const RemoteCheckoutSessionModel({
    required this.url,
    required this.sessionId,
  });

  factory RemoteCheckoutSessionModel.fromJson(Map<String, dynamic> json) =>
      RemoteCheckoutSessionModel(
        url: json['url'] as String,
        sessionId: json['sessionId'] as String,
      );

  final String url;
  final String sessionId;
}
