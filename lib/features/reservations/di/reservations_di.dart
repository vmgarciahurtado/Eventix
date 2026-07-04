import 'package:eventix/core/services/supabase/supabase_provider.dart';
import 'package:eventix/features/payments/di/payments_di.dart';
import 'package:eventix/features/reservations/domain/repositories/reservations_repository.dart';
import 'package:eventix/features/reservations/domain/usecases/cancel_pending_reservation.dart';
import 'package:eventix/features/reservations/domain/usecases/create_reservation.dart';
import 'package:eventix/features/reservations/domain/usecases/get_my_reservations.dart';
import 'package:eventix/features/reservations/domain/usecases/purchase_tickets.dart';
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

final Provider<CreateReservation> createReservationProvider =
    Provider<CreateReservation>(
      (Ref ref) => CreateReservation(ref.watch(reservationsRepositoryProvider)),
    );

final Provider<CancelPendingReservation> cancelPendingReservationProvider =
    Provider<CancelPendingReservation>(
      (Ref ref) => CancelPendingReservation(
        ref.watch(reservationsRepositoryProvider),
      ),
    );

final Provider<GetMyReservations> getMyReservationsProvider =
    Provider<GetMyReservations>(
      (Ref ref) =>
          GetMyReservations(ref.watch(reservationsRepositoryProvider)),
    );

/// Orquestador de compra: coordina reservas y pagos contra interfaces.
final Provider<PurchaseTickets> purchaseTicketsProvider =
    Provider<PurchaseTickets>(
      (Ref ref) => PurchaseTickets(
        reservations: ref.watch(reservationsRepositoryProvider),
        payments: ref.watch(paymentsRepositoryProvider),
      ),
    );
