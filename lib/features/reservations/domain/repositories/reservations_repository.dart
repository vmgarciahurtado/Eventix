import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/reservations/domain/entities/reservation.dart';

abstract interface class ReservationsRepository {
  /// Crea una reserva (simula la compra) y devuelve la reserva creada.
  Future<Result<Reservation>> createReservation({
    required String eventId,
    required int quantity,
  });

  Future<Result<List<Reservation>>> getMyReservations();
}
