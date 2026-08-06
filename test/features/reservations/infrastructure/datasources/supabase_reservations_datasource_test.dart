import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/features/reservations/infrastructure/datasources/supabase_reservations_datasource.dart';
import 'package:eventix/features/reservations/infrastructure/models/remote_reservation_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_supabase.dart';

Map<String, dynamic> _reservationRow({String status = 'pending'}) =>
    <String, dynamic>{
      'id': 'res-1',
      'event_id': 'evt-1',
      'quantity': 2,
      'status': status,
      'created_at': '2026-06-29T15:00:00Z',
      'events': <String, dynamic>{
        'title': 'Festival de Reggaetón',
        'starts_at': '2026-07-04T20:00:00Z',
      },
    };

void main() {
  late FakeSupabase supabase;

  void useResponse(Object? body) {
    supabase = FakeSupabase.replying(body);
    addTearDown(supabase.dispose);
  }

  SupabaseReservationsDatasource datasource() =>
      SupabaseReservationsDatasource(supabase.client);

  group('createReservation', () {
    test('inserta la fila con evento, cantidad y estado', () async {
      useResponse(_reservationRow());

      final RemoteReservationModel reservation = await datasource()
          .createReservation(
            eventId: 'evt-1',
            quantity: 2,
            status: 'pending',
          );

      expect(supabase.lastRequest.method, 'POST');
      expect(supabase.lastUri.path, endsWith('/rest/v1/reservations'));
      expect(supabase.lastBody, <String, dynamic>{
        'event_id': 'evt-1',
        'quantity': 2,
        'status': 'pending',
      });
      expect(reservation.id, 'res-1');
    });

    test('NO manda user_id: lo pone la BD desde la sesión', () async {
      // Si el cliente lo mandara, podría reservar a nombre de otro.
      useResponse(_reservationRow());

      await datasource().createReservation(
        eventId: 'evt-1',
        quantity: 1,
        status: 'pending',
      );

      expect(supabase.lastBody.containsKey('user_id'), isFalse);
    });

    test('pide de vuelta la fila con el evento embebido', () async {
      useResponse(_reservationRow());

      final RemoteReservationModel reservation = await datasource()
          .createReservation(
            eventId: 'evt-1',
            quantity: 1,
            status: 'confirmed',
          );

      expect(supabase.lastQuery['select'], '*,events(title,starts_at)');
      expect(reservation.eventTitle, 'Festival de Reggaetón');
    });

    test('un rechazo del servidor se traduce a Failure', () async {
      supabase = FakeSupabase.failing(status: 409);
      addTearDown(supabase.dispose);

      expect(
        () => datasource().createReservation(
          eventId: 'evt-1',
          quantity: 99,
          status: 'pending',
        ),
        throwsA(isA<Failure>()),
      );
    });
  });

  group('deletePendingReservation', () {
    test('borra por id', () async {
      useResponse(<Map<String, dynamic>>[]);

      await datasource().deletePendingReservation(id: 'res-1');

      expect(supabase.lastRequest.method, 'DELETE');
      expect(supabase.lastQuery['id'], 'eq.res-1');
    });
  });

  group('fetchMyReservations', () {
    test('trae las reservas con su evento, de la más nueva a la más vieja',
        () async {
      useResponse(<Map<String, dynamic>>[_reservationRow(status: 'confirmed')]);

      final List<RemoteReservationModel> reservations = await datasource()
          .fetchMyReservations();

      expect(supabase.lastQuery['select'], '*,events(title,starts_at)');
      expect(supabase.lastQuery['order'], contains('created_at'));
      expect(supabase.lastQuery['order'], contains('desc'));
      expect(reservations.single.status, 'confirmed');
    });

    test('NO filtra por usuario: de eso se encarga RLS', () async {
      // Quién decide qué filas se ven es la política de la tabla.
      useResponse(<Map<String, dynamic>>[]);

      await datasource().fetchMyReservations();

      expect(supabase.lastQuery.containsKey('user_id'), isFalse);
    });
  });
}
