import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/errors/map_supabase_error.dart';
import 'package:eventix/features/payments/domain/entities/checkout_session.dart';
import 'package:eventix/features/payments/infrastructure/datasources/payments_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabasePaymentsDatasource implements PaymentsDatasource {
  const SupabasePaymentsDatasource(this._client);

  final SupabaseClient _client;

  Future<T> _guard<T>(Future<T> Function() fn) async {
    try {
      return await fn();
    } on FunctionException catch (e) {
      throw ServerFailure(_messageFrom(e) ?? 'No se pudo procesar el pago');
    } catch (e) {
      throw mapSupabaseError(e);
    }
  }

  /// Las funciones devuelven `{ "error": "..." }` en los fallos controlados.
  String? _messageFrom(FunctionException e) {
    final Object? details = e.details;
    if (details is Map && details['error'] is String) {
      return details['error'] as String;
    }
    return null;
  }

  @override
  Future<CheckoutSession> createCheckout({
    required String eventId,
    required int quantity,
    required bool wantInvoice,
  }) => _guard(() async {
    final FunctionResponse res = await _client.functions.invoke(
      'stripe-create-checkout',
      body: <String, dynamic>{
        'eventId': eventId,
        'quantity': quantity,
        'wantInvoice': wantInvoice,
      },
    );
    final Map<String, dynamic> data = res.data as Map<String, dynamic>;
    return CheckoutSession(
      url: data['url'] as String,
      sessionId: data['sessionId'] as String,
    );
  });

  @override
  Future<bool> verifyCheckout({required String sessionId}) => _guard(() async {
    final FunctionResponse res = await _client.functions.invoke(
      'stripe-verify-checkout',
      body: <String, dynamic>{'sessionId': sessionId},
    );
    final Map<String, dynamic> data = res.data as Map<String, dynamic>;
    return data['paid'] == true;
  });
}
