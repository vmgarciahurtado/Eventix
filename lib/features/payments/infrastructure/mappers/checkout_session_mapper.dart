import 'package:eventix/features/payments/domain/entities/checkout_session.dart';
import 'package:eventix/features/payments/infrastructure/models/remote_checkout_session_model.dart';

abstract final class CheckoutSessionMapper {
  /// Ruta de la Edge Function a la que redirige la pasarela al terminar. Se
  /// asume mientras el payload no la traiga; si la devuelve, manda esa.
  static const String _defaultReturnUrlMarker = '/stripe-return';

  static RemoteCheckoutSessionModel fromJson(Map<String, dynamic> json) {
    return RemoteCheckoutSessionModel(
      url: json['url'] as String,
      sessionId: json['sessionId'] as String,
      returnUrlMarker:
          json['returnUrlMarker'] as String? ?? _defaultReturnUrlMarker,
    );
  }

  static CheckoutSession toEntity(RemoteCheckoutSessionModel m) {
    return CheckoutSession(
      url: m.url,
      sessionId: m.sessionId,
      returnUrlMarker: m.returnUrlMarker,
    );
  }
}
