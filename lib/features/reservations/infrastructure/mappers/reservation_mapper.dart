import 'package:eventix/features/reservations/domain/entities/reservation.dart';
import 'package:eventix/features/reservations/domain/entities/reservation_status.dart';
import 'package:eventix/features/reservations/infrastructure/models/remote_reservation_model.dart';

abstract final class ReservationMapper {
  static Reservation toEntity(RemoteReservationModel m) => Reservation(
    id: m.id,
    eventId: m.eventId,
    eventTitle: m.eventTitle,
    quantity: m.quantity,
    status: ReservationStatus.fromName(m.status),
    createdAt: m.createdAt,
    eventStartsAt: m.eventStartsAt,
  );
}
