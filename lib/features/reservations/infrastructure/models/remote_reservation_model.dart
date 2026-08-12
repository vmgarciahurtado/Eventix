class RemoteReservationModel {
  const RemoteReservationModel({
    required this.id,
    required this.eventId,
    required this.quantity,
    required this.status,
    required this.createdAt,
    required this.eventTitle,
    required this.eventStartsAt,
  });

  final String id;
  final String eventId;
  final int quantity;
  final String status;
  final DateTime createdAt;
  final String eventTitle;
  final DateTime? eventStartsAt;
}
