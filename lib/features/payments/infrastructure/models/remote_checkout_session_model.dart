/// Payload de `stripe-create-checkout`.
class RemoteCheckoutSessionModel {
  const RemoteCheckoutSessionModel({
    required this.url,
    required this.sessionId,
    required this.returnUrlMarker,
  });

  factory RemoteCheckoutSessionModel.fromJson(Map<String, dynamic> json) =>
      RemoteCheckoutSessionModel(
        url: json['url'] as String,
        sessionId: json['sessionId'] as String,
        returnUrlMarker:
            json['returnUrlMarker'] as String? ?? _defaultReturnUrlMarker,
      );

  /// Ruta de la Edge Function a la que redirige la pasarela al terminar. Se
  /// asume mientras el payload no la traiga; si la devuelve, manda esa.
  static const String _defaultReturnUrlMarker = '/stripe-return';

  final String url;
  final String sessionId;
  final String returnUrlMarker;
}
