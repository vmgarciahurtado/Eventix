import 'package:eventix/core/errors/supabase_guard.dart';
import 'package:eventix/features/payments/domain/entities/checkout_session.dart';
import 'package:eventix/features/payments/domain/entities/payment_verification.dart';
import 'package:eventix/features/payments/infrastructure/datasources/payments_datasource.dart';
import 'package:eventix/features/payments/infrastructure/mappers/payment_mappers.dart';
import 'package:eventix/features/payments/infrastructure/models/remote_checkout_session_model.dart';
import 'package:eventix/features/payments/infrastructure/models/remote_payment_verification_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabasePaymentsDatasource implements PaymentsDatasource {
  const SupabasePaymentsDatasource(this._client);

  final SupabaseClient _client;

  @override
  Future<CheckoutSession> createCheckout({
    required String reservationId,
    required bool wantInvoice,
  }) => guardSupabaseCall(() async {
    final FunctionResponse res = await _client.functions.invoke(
      'stripe-create-checkout',
      body: <String, dynamic>{
        'reservationId': reservationId,
        'wantInvoice': wantInvoice,
      },
    );
    final RemoteCheckoutSessionModel model =
        RemoteCheckoutSessionModel.fromJson(
          res.data as Map<String, dynamic>,
        );
    return PaymentMappers.toCheckoutSession(model);
  });

  @override
  Future<PaymentVerification> verifyCheckout({required String sessionId}) =>
      guardSupabaseCall(() async {
        final FunctionResponse res = await _client.functions.invoke(
          'stripe-verify-checkout',
          body: <String, dynamic>{'sessionId': sessionId},
        );
        final RemotePaymentVerificationModel model =
            RemotePaymentVerificationModel.fromJson(
              res.data as Map<String, dynamic>,
            );
        return PaymentMappers.toPaymentVerification(model);
      });
}
