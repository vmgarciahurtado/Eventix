import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/reservations/domain/entities/reservation.dart';
import 'package:eventix/features/reservations/domain/enums/reservation_status.dart';
import 'package:eventix/features/reservations/infrastructure/datasources/reservations_datasource.dart';
import 'package:eventix/features/reservations/infrastructure/models/remote_reservation_model.dart';
import 'package:eventix/features/reservations/infrastructure/repositories/reservations_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockReservationsDatasource extends Mock
    implements ReservationsDatasource {}

RemoteReservationModel _tReservation() => RemoteReservationModel(
  id: 'res-1',
  eventId: 'evt-1',
  quantity: 2,
  status: 'confirmed',
  createdAt: DateTime.utc(2026, 6, 29),
  eventTitle: 'Festival',
  eventStartsAt: DateTime.utc(2026, 7, 4, 20),
);

void main() {
  late _MockReservationsDatasource datasource;
  late ReservationsRepositoryImpl repository;

  setUp(() {
    datasource = _MockReservationsDatasource();
    repository = ReservationsRepositoryImpl(datasource);
  });

  test('createReservation maps the created model into an entity', () async {
    when(
      () => datasource.createReservation(
        eventId: any(named: 'eventId'),
        quantity: any(named: 'quantity'),
        status: any(named: 'status'),
      ),
    ).thenAnswer((_) async => _tReservation());

    final Result<Reservation> result = await repository.createReservation(
      eventId: 'evt-1',
      quantity: 2,
      initialStatus: ReservationStatus.confirmed,
    );

    expect(result, isA<Success<Reservation>>());
    final Reservation reservation = (result as Success<Reservation>).data;
    expect(reservation.quantity, 2);
    expect(reservation.status, ReservationStatus.confirmed);
    expect(reservation.eventTitle, 'Festival');
    verify(
      () => datasource.createReservation(
        eventId: 'evt-1',
        quantity: 2,
        status: 'confirmed',
      ),
    ).called(1);
  });

  test('getMyReservations maps the list of models', () async {
    when(datasource.fetchMyReservations).thenAnswer(
      (_) async => <RemoteReservationModel>[_tReservation()],
    );

    final Result<List<Reservation>> result = await repository
        .getMyReservations();

    expect(result, isA<Success<List<Reservation>>>());
    expect((result as Success<List<Reservation>>).data, hasLength(1));
  });
}
