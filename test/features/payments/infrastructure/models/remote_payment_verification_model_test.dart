import 'package:eventix/features/payments/domain/entities/payment_verification.dart';
import 'package:eventix/features/payments/infrastructure/mappers/payment_verification_mapper.dart';
import 'package:eventix/features/payments/infrastructure/models/remote_payment_verification_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parsea el payload de la edge function', () {
    final RemotePaymentVerificationModel model =
        RemotePaymentVerificationModel.fromJson(<String, dynamic>{
          'paid': true,
          'confirmed': true,
        });

    expect(model.paid, isTrue);
    expect(model.confirmed, isTrue);
  });

  test('solo un true literal cuenta como pagado', () {
    // Solo el true literal cuenta: 'true', 1 o null no son un cobro.
    for (final Object? value in <Object?>[null, 'true', 1, 'si', 0]) {
      expect(
        RemotePaymentVerificationModel.fromJson(<String, dynamic>{
          'paid': value,
        }).paid,
        isFalse,
        reason: 'paid no debería ser true con $value',
      );
    }
  });

  test('un payload vacío se interpreta como no pagado y no confirmado', () {
    final RemotePaymentVerificationModel model =
        RemotePaymentVerificationModel.fromJson(<String, dynamic>{});

    expect(model.paid, isFalse);
    expect(model.confirmed, isFalse);
  });

  test('el mapper renombra confirmed a reservationConfirmed', () {
    final PaymentVerification verification =
        PaymentVerificationMapper.toEntity(
          const RemotePaymentVerificationModel(paid: true, confirmed: false),
        );

    expect(verification.paid, isTrue);
    expect(verification.reservationConfirmed, isFalse);
  });
}
