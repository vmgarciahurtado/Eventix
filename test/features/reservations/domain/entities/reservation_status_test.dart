import 'package:eventix/features/reservations/domain/enums/reservation_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReservationStatus.fromName', () {
    test('maps "confirmed" to confirmed', () {
      expect(
        ReservationStatus.fromName('confirmed'),
        ReservationStatus.confirmed,
      );
    });

    test('maps "pending" to pending', () {
      expect(ReservationStatus.fromName('pending'), ReservationStatus.pending);
    });

    test('falls back to pending for any unknown value', () {
      expect(ReservationStatus.fromName(''), ReservationStatus.pending);
      expect(ReservationStatus.fromName('garbage'), ReservationStatus.pending);
    });
  });

  group('ReservationStatus.label', () {
    test('exposes a human label per status', () {
      expect(ReservationStatus.confirmed.label, 'Confirmada');
      expect(ReservationStatus.pending.label, 'Pendiente');
    });
  });
}
