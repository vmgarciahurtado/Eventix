import 'package:eventix/features/reservations/domain/entities/reservation.dart';
import 'package:eventix/features/reservations/domain/enums/reservation_status.dart';
import 'package:eventix/features/reservations/infrastructure/mappers/reservation_mapper.dart';
import 'package:eventix/features/reservations/infrastructure/models/remote_reservation_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('fromJson', () {
    test('parsea una fila con el evento embebido por el join', () {
      final RemoteReservationModel model = RemoteReservationModel.fromJson(
        <String, dynamic>{
          'id': 'res-1',
          'event_id': 'evt-1',
          'quantity': 2,
          'status': 'confirmed',
          'created_at': '2026-06-29T15:00:00Z',
          'events': <String, dynamic>{
            'title': 'Festival de Reggaetón',
            'starts_at': '2026-07-04T20:00:00Z',
          },
        },
      );

      expect(model.id, 'res-1');
      expect(model.eventId, 'evt-1');
      expect(model.quantity, 2);
      expect(model.status, 'confirmed');
      expect(model.createdAt, DateTime.utc(2026, 6, 29, 15));
      expect(model.eventTitle, 'Festival de Reggaetón');
      expect(model.eventStartsAt, DateTime.utc(2026, 7, 4, 20));
    });

    test('tolera que el join no traiga el evento', () {
      // Pasa cuando el evento se borró: la reserva sigue siendo del usuario y
      // la pantalla no debe caerse por eso.
      final RemoteReservationModel model = RemoteReservationModel.fromJson(
        <String, dynamic>{
          'id': 'res-1',
          'event_id': 'evt-1',
          'quantity': 1,
          'status': 'pending',
          'created_at': '2026-06-29T15:00:00Z',
        },
      );

      expect(model.eventTitle, '');
      expect(model.eventStartsAt, isNull);
    });

    test('acepta quantity como double, que es lo que manda PostgREST', () {
      final RemoteReservationModel model = RemoteReservationModel.fromJson(
        <String, dynamic>{
          'id': 'res-1',
          'event_id': 'evt-1',
          'quantity': 3.0,
          'status': 'pending',
          'created_at': '2026-06-29T15:00:00Z',
        },
      );

      expect(model.quantity, 3);
    });

    test('lanza si falta un campo obligatorio', () {
      expect(
        () => RemoteReservationModel.fromJson(<String, dynamic>{
          'event_id': 'evt-1',
          'quantity': 1,
          'status': 'pending',
          'created_at': '2026-06-29T15:00:00Z',
        }),
        throwsA(isA<TypeError>()),
      );
    });

    test('lanza si created_at no es una fecha válida', () {
      expect(
        () => RemoteReservationModel.fromJson(<String, dynamic>{
          'id': 'res-1',
          'event_id': 'evt-1',
          'quantity': 1,
          'status': 'pending',
          'created_at': 'ayer',
        }),
        throwsFormatException,
      );
    });
  });

  group('ReservationMapper', () {
    RemoteReservationModel model(String status) => RemoteReservationModel(
      id: 'res-1',
      eventId: 'evt-1',
      quantity: 2,
      status: status,
      createdAt: DateTime.utc(2026, 6, 29),
      eventTitle: 'Festival',
      eventStartsAt: DateTime.utc(2026, 7, 4),
    );

    test('traduce el status de texto al enum del dominio', () {
      final Reservation reservation = ReservationMapper.toEntity(
        model('confirmed'),
      );

      expect(reservation.status, ReservationStatus.confirmed);
      expect(reservation.eventTitle, 'Festival');
      expect(reservation.quantity, 2);
    });

    test('un status desconocido cae en pending, no rompe la pantalla', () {
      expect(
        ReservationMapper.toEntity(model('refunded')).status,
        ReservationStatus.pending,
      );
    });
  });
}
