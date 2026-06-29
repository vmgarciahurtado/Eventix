import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/core/services/supabase/supabase_provider.dart';
import 'package:eventix/features/reservations/domain/entities/reservation.dart';
import 'package:eventix/features/reservations/domain/repositories/reservations_repository.dart';
import 'package:eventix/features/reservations/domain/usecases/create_reservation.dart';
import 'package:eventix/features/reservations/domain/usecases/get_my_reservations.dart';
import 'package:eventix/features/reservations/infrastructure/datasources/reservations_datasource.dart';
import 'package:eventix/features/reservations/infrastructure/datasources/supabase_reservations_datasource.dart';
import 'package:eventix/features/reservations/infrastructure/repositories/reservations_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

final Provider<GetMyReservations> getMyReservationsProvider =
    Provider<GetMyReservations>(
      (Ref ref) =>
          GetMyReservations(ref.watch(reservationsRepositoryProvider)),
    );

final FutureProvider<List<Reservation>> myReservationsProvider =
    FutureProvider<List<Reservation>>((Ref ref) async {
      final Result<List<Reservation>> result = await ref
          .watch(getMyReservationsProvider)
          .call();
      return result.getOrThrow();
    });
