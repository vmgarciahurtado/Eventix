import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/reservations/domain/entities/reservation.dart';
import 'package:eventix/features/reservations/domain/entities/reservation_status.dart';

abstract interface class ReservationsRepository {
  /// Crea una reserva y devuelve la reserva creada.
  ///
  /// Los eventos gratuitos se crean [ReservationStatus.confirmed]; los pagos
  /// deben crearse [ReservationStatus.pending] (el backend rechaza confirmar
  /// sin pago) y se confirman server-side al verificar el checkout.
  Future<Result<Reservation>> createReservation({
    required String eventId,
    required int quantity,
    required ReservationStatus initialStatus,
  });

  /// Elimina una reserva propia que siga pendiente (p. ej. pago cancelado),
  /// liberando el cupo retenido.
  Future<Result<void>> cancelPendingReservation({required String id});

  Future<Result<List<Reservation>>> getMyReservations();
}
