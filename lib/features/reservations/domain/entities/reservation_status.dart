/// Estado de una reserva.
enum ReservationStatus {
  pending,
  confirmed;

  static ReservationStatus fromName(String value) => switch (value) {
    'confirmed' => ReservationStatus.confirmed,
    _ => ReservationStatus.pending,
  };

  String get label => switch (this) {
    ReservationStatus.confirmed => 'Confirmada',
    ReservationStatus.pending => 'Pendiente',
  };
}
