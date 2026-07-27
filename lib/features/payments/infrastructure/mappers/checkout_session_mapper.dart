import 'package:eventix/features/payments/domain/entities/checkout_session.dart';
import 'package:eventix/features/payments/infrastructure/models/remote_checkout_session_model.dart';

abstract final class CheckoutSessionMapper {
  static CheckoutSession toEntity(RemoteCheckoutSessionModel m) =>
      CheckoutSession(
        url: m.url,
        sessionId: m.sessionId,
        returnUrlMarker: m.returnUrlMarker,
      );
}
