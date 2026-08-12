import 'package:eventix/core/services/supabase/supabase_provider.dart';
import 'package:eventix/features/payments/domain/repositories/payments_repository.dart';
import 'package:eventix/features/payments/domain/usecases/create_checkout_session_use_case.dart';
import 'package:eventix/features/payments/domain/usecases/verify_checkout_session_use_case.dart';
import 'package:eventix/features/payments/infrastructure/datasources/payments_datasource.dart';
import 'package:eventix/features/payments/infrastructure/datasources/supabase_payments_datasource.dart';
import 'package:eventix/features/payments/infrastructure/repositories/payments_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Composition root de la feature payments.
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

final Provider<CreateCheckoutSessionUseCase> createCheckoutSessionProvider =
    Provider<CreateCheckoutSessionUseCase>(
      (Ref ref) =>
          CreateCheckoutSessionUseCase(ref.watch(paymentsRepositoryProvider)),
    );

final Provider<VerifyCheckoutSessionUseCase> verifyCheckoutSessionProvider =
    Provider<VerifyCheckoutSessionUseCase>(
      (Ref ref) =>
          VerifyCheckoutSessionUseCase(ref.watch(paymentsRepositoryProvider)),
    );
