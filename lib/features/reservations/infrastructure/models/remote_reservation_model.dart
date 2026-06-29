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

  factory RemoteReservationModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? event =
        json['events'] as Map<String, dynamic>?;
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

  final String id;
  final String eventId;
  final int quantity;
  final String status;
  final DateTime createdAt;
  final String eventTitle;
  final DateTime? eventStartsAt;
}
