import 'package:eventix/features/reservations/infrastructure/models/remote_reservation_model.dart';

abstract interface class ReservationsDatasource {
  Future<RemoteReservationModel> createReservation({
    required String eventId,
    required int quantity,
  });

  Future<List<RemoteReservationModel>> fetchMyReservations();
}
