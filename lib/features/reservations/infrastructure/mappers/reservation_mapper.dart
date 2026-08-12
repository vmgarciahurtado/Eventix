import 'package:eventix/features/reservations/domain/entities/reservation.dart';
import 'package:eventix/features/reservations/domain/enums/reservation_status.dart';
import 'package:eventix/features/reservations/infrastructure/models/remote_reservation_model.dart';

abstract final class ReservationMapper {
  static RemoteReservationModel fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? event = json['events'] as Map<String, dynamic>?;
    final String? startsAt = event?['starts_at'] as String?;
    return RemoteReservationModel(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      quantity: (json['quantity'] as num).toInt(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      eventTitle: (event?['title'] as String?) ?? '',
      eventStartsAt: startsAt == null ? null : DateTime.parse(startsAt),
    );
  }

  static Reservation toEntity(RemoteReservationModel m) {
    return Reservation(
      id: m.id,
      eventTitle: m.eventTitle,
      quantity: m.quantity,
      status: ReservationStatus.fromName(m.status),
      createdAt: m.createdAt,
      eventStartsAt: m.eventStartsAt,
    );
  }
}
