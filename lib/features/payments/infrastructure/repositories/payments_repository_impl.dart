import 'package:eventix/core/helpers/execute_repository_call.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/payments/domain/entities/checkout_session.dart';
import 'package:eventix/features/payments/domain/entities/payment_verification.dart';
import 'package:eventix/features/payments/domain/repositories/payments_repository.dart';
import 'package:eventix/features/payments/infrastructure/datasources/payments_datasource.dart';

class PaymentsRepositoryImpl implements PaymentsRepository {
  const PaymentsRepositoryImpl(this._datasource);

  final PaymentsDatasource _datasource;

  @override
  Future<Result<CheckoutSession>> createCheckout({
    required String reservationId,
    required bool wantInvoice,
  }) => executeRepositoryCall(
    () => _datasource.createCheckout(
      reservationId: reservationId,
      wantInvoice: wantInvoice,
    ),
  );

  @override
  Future<Result<PaymentVerification>> verifyCheckout({
    required String sessionId,
  }) => executeRepositoryCall(
    () => _datasource.verifyCheckout(sessionId: sessionId),
  );
}
