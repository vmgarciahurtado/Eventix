/// Payload de `stripe-create-checkout`.
class RemoteCheckoutSessionModel {
  const RemoteCheckoutSessionModel({
    required this.url,
    required this.sessionId,
    required this.returnUrlMarker,
  });

  final String url;
  final String sessionId;
  final String returnUrlMarker;
}
