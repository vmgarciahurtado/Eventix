import 'package:eventix/features/payments/infrastructure/models/remote_checkout_session_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromJson usa el returnUrlMarker que envía el servidor', () {
    final RemoteCheckoutSessionModel model =
        RemoteCheckoutSessionModel.fromJson(<String, dynamic>{
          'url': 'https://checkout.test/abc',
          'sessionId': 'cs_test_123',
          'returnUrlMarker': '/wompi-return',
        });

    expect(model.url, 'https://checkout.test/abc');
    expect(model.sessionId, 'cs_test_123');
    expect(model.returnUrlMarker, '/wompi-return');
  });

  test('fromJson cae al marcador por defecto si el payload no lo trae', () {
    final RemoteCheckoutSessionModel model =
        RemoteCheckoutSessionModel.fromJson(<String, dynamic>{
          'url': 'https://checkout.test/abc',
          'sessionId': 'cs_test_123',
        });

    expect(model.returnUrlMarker, '/stripe-return');
  });
}
