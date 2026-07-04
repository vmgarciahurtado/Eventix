import 'package:eventix/features/reservations/infrastructure/models/remote_reservation_model.dart';

abstract interface class ReservationsDatasource {
  Future<RemoteReservationModel> createReservation({
    required String eventId,
    required int quantity,
    required String status,
  });

  /// Borra una reserva propia pendiente (la RLS solo permite borrar
  /// `pending` del propio usuario).
  Future<void> deletePendingReservation({required String id});

  Future<List<RemoteReservationModel>> fetchMyReservations();
}
