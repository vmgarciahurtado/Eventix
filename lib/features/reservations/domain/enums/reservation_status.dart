/// Estado de una reserva.
enum ReservationStatus {
  pending,
  confirmed;

  static ReservationStatus fromName(String value) {
    return switch (value) {
      'confirmed' => ReservationStatus.confirmed,
      _ => ReservationStatus.pending,
    };
  }

  String get label {
    return switch (this) {
      ReservationStatus.confirmed => 'Confirmada',
      ReservationStatus.pending => 'Pendiente',
    };
  }
}
