import 'package:eventix/features/reservations/domain/entities/reservation_status.dart';

/// Reserva de cupos para un evento, hecha por el usuario autenticado.
class Reservation {
  const Reservation({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.quantity,
    required this.status,
    required this.createdAt,
    required this.eventStartsAt,
  });

  final String id;
  final String eventId;
  final String eventTitle;
  final int quantity;
  final ReservationStatus status;
  final DateTime createdAt;
  final DateTime? eventStartsAt;
}
