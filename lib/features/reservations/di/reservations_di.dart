import 'package:eventix/core/services/supabase/supabase_provider.dart';
import 'package:eventix/features/payments/di/payments_di.dart';
import 'package:eventix/features/reservations/domain/repositories/reservations_repository.dart';
import 'package:eventix/features/reservations/domain/usecases/cancel_pending_reservation_use_case.dart';
import 'package:eventix/features/reservations/domain/usecases/complete_payment_use_case.dart';
import 'package:eventix/features/reservations/domain/usecases/create_reservation_use_case.dart';
import 'package:eventix/features/reservations/domain/usecases/get_my_reservations_use_case.dart';
import 'package:eventix/features/reservations/domain/usecases/start_purchase_use_case.dart';
import 'package:eventix/features/reservations/infrastructure/datasources/reservations_datasource.dart';
import 'package:eventix/features/reservations/infrastructure/datasources/supabase_reservations_datasource.dart';
import 'package:eventix/features/reservations/infrastructure/repositories/reservations_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Composition root de la feature reservations.
final Provider<ReservationsDatasource> reservationsDatasourceProvider =
    Provider<ReservationsDatasource>(
      (Ref ref) =>
          SupabaseReservationsDatasource(ref.watch(supabaseClientProvider)),
    );

final Provider<ReservationsRepository> reservationsRepositoryProvider =
    Provider<ReservationsRepository>(
      (Ref ref) =>
          ReservationsRepositoryImpl(ref.watch(reservationsDatasourceProvider)),
    );

final Provider<CreateReservationUseCase> createReservationProvider =
    Provider<CreateReservationUseCase>(
      (Ref ref) =>
          CreateReservationUseCase(ref.watch(reservationsRepositoryProvider)),
    );

final Provider<CancelPendingReservationUseCase>
cancelPendingReservationProvider = Provider<CancelPendingReservationUseCase>(
  (Ref ref) => CancelPendingReservationUseCase(
    ref.watch(reservationsRepositoryProvider),
  ),
);

final Provider<GetMyReservationsUseCase> getMyReservationsProvider =
    Provider<GetMyReservationsUseCase>(
      (Ref ref) =>
          GetMyReservationsUseCase(ref.watch(reservationsRepositoryProvider)),
    );

/// Inicia la compra: compone usecases propios y la API pública de payments
final Provider<StartPurchaseUseCase> startPurchaseProvider =
    Provider<StartPurchaseUseCase>(
      (Ref ref) => StartPurchaseUseCase(
        createReservation: ref.watch(createReservationProvider),
        cancelPendingReservation: ref.watch(cancelPendingReservationProvider),
        createCheckout: ref.watch(createCheckoutSessionProvider),
      ),
    );

/// Verifica el pago tras el checkout e interpreta el resultado.
final Provider<CompletePaymentUseCase> completePaymentProvider =
    Provider<CompletePaymentUseCase>(
      (Ref ref) =>
          CompletePaymentUseCase(ref.watch(verifyCheckoutSessionProvider)),
    );
