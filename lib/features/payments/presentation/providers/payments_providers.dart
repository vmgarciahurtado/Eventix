import 'package:eventix/core/services/supabase/supabase_provider.dart';
import 'package:eventix/features/payments/domain/repositories/payments_repository.dart';
import 'package:eventix/features/payments/domain/usecases/create_checkout_session.dart';
import 'package:eventix/features/payments/domain/usecases/verify_checkout_session.dart';
import 'package:eventix/features/payments/infrastructure/datasources/payments_datasource.dart';
import 'package:eventix/features/payments/infrastructure/datasources/supabase_payments_datasource.dart';
import 'package:eventix/features/payments/infrastructure/repositories/payments_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<PaymentsDatasource> paymentsDatasourceProvider =
    Provider<PaymentsDatasource>(
      (Ref ref) =>
          SupabasePaymentsDatasource(ref.watch(supabaseClientProvider)),
    );

final Provider<PaymentsRepository> paymentsRepositoryProvider =
    Provider<PaymentsRepository>(
      (Ref ref) =>
          PaymentsRepositoryImpl(ref.watch(paymentsDatasourceProvider)),
    );

final Provider<CreateCheckoutSession> createCheckoutSessionProvider =
    Provider<CreateCheckoutSession>(
      (Ref ref) =>
          CreateCheckoutSession(ref.watch(paymentsRepositoryProvider)),
    );

final Provider<VerifyCheckoutSession> verifyCheckoutSessionProvider =
    Provider<VerifyCheckoutSession>(
      (Ref ref) =>
          VerifyCheckoutSession(ref.watch(paymentsRepositoryProvider)),
    );
