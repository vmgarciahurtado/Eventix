import 'package:eventix/features/payments/domain/enums/checkout_result.dart';
import 'package:flutter_test/flutter_test.dart';

/// Traduce el `status` con el que la pasarela devuelve al usuario.
void main() {
  test('solo "success" exacto cuenta como pago exitoso', () {
    expect(CheckoutResult.fromStatus('success'), CheckoutResult.success);
  });

  test('cualquier otro valor se asume cancelación', () {
    for (final String? status in <String?>[
      null,
      '',
      'cancel',
      'Success',
      'SUCCESS',
      ' success',
      'success ',
      'succeeded',
      'true',
      '1',
    ]) {
      expect(
        CheckoutResult.fromStatus(status),
        CheckoutResult.cancel,
        reason: 'un status "$status" no puede dar por bueno un pago',
      );
    }
  });

  test('no hay más resultados que éxito y cancelación', () {
    // Un tercer caso rompería el switch exhaustivo de la página de reserva.
    expect(CheckoutResult.values, <CheckoutResult>[
      CheckoutResult.success,
      CheckoutResult.cancel,
    ]);
  });
}
