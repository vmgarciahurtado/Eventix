import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/features/payments/domain/entities/checkout_session.dart';
import 'package:eventix/features/payments/domain/entities/payment_verification.dart';
import 'package:eventix/features/payments/infrastructure/datasources/supabase_payments_datasource.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_supabase.dart';

void main() {
  late FakeSupabase supabase;

  void useResponse(Object? body) {
    supabase = FakeSupabase.replying(body);
    addTearDown(supabase.dispose);
  }

  SupabasePaymentsDatasource datasource() =>
      SupabasePaymentsDatasource(supabase.client);

  group('createCheckout', () {
    test('invoca la edge function con la reserva y la preferencia', () async {
      useResponse(<String, dynamic>{
        'url': 'https://checkout.stripe.test/cs_test_123',
        'sessionId': 'cs_test_123',
        'returnUrlMarker': '/stripe-return',
      });

      final CheckoutSession session = await datasource().createCheckout(
        reservationId: 'res-1',
        wantInvoice: true,
      );

      expect(
        supabase.lastUri.path,
        endsWith('/functions/v1/stripe-create-checkout'),
      );
      expect(supabase.lastBody, <String, dynamic>{
        'reservationId': 'res-1',
        'wantInvoice': true,
      });
      expect(session.sessionId, 'cs_test_123');
      expect(session.returnUrlMarker, '/stripe-return');
    });

    test('NO manda monto ni cantidad: los resuelve el servidor', () async {
      // Si el cliente mandara el precio, podría pagar lo que quisiera.
      useResponse(<String, dynamic>{
        'url': 'https://checkout.stripe.test/cs',
        'sessionId': 'cs',
      });

      await datasource().createCheckout(
        reservationId: 'res-1',
        wantInvoice: false,
      );

      expect(supabase.lastBody.containsKey('amount'), isFalse);
      expect(supabase.lastBody.containsKey('quantity'), isFalse);
      expect(supabase.lastBody.containsKey('unitPrice'), isFalse);
    });

    test('si el payload no trae marcador usa el de por defecto', () async {
      useResponse(<String, dynamic>{
        'url': 'https://checkout.stripe.test/cs',
        'sessionId': 'cs',
      });

      final CheckoutSession session = await datasource().createCheckout(
        reservationId: 'res-1',
        wantInvoice: false,
      );

      expect(session.returnUrlMarker, '/stripe-return');
    });

    test('un fallo de la function se traduce a Failure', () async {
      supabase = FakeSupabase.failing();
      addTearDown(supabase.dispose);

      expect(
        () => datasource().createCheckout(
          reservationId: 'res-1',
          wantInvoice: false,
        ),
        throwsA(isA<Failure>()),
      );
    });
  });

  group('verifyCheckout', () {
    test('invoca la verificación con el id de sesión', () async {
      useResponse(<String, dynamic>{'paid': true, 'confirmed': true});

      final PaymentVerification verification = await datasource()
          .verifyCheckout(sessionId: 'cs_test_123');

      expect(
        supabase.lastUri.path,
        endsWith('/functions/v1/stripe-verify-checkout'),
      );
      expect(supabase.lastBody, <String, dynamic>{
        'sessionId': 'cs_test_123',
      });
      expect(verification.paid, isTrue);
      expect(verification.reservationConfirmed, isTrue);
    });

    test('pagado pero sin confirmar llega como tal, no como éxito', () async {
      useResponse(<String, dynamic>{'paid': true, 'confirmed': false});

      final PaymentVerification verification = await datasource()
          .verifyCheckout(sessionId: 'cs_test_123');

      expect(verification.paid, isTrue);
      expect(verification.reservationConfirmed, isFalse);
    });
  });
}
