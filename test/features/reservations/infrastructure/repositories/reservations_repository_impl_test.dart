import 'package:eventix/core/errors/failure.dart';
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

  test('createReservation mapea el modelo creado a entidad', () async {
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

  test('createReservation traduce el estado inicial a texto', () async {
    when(
      () => datasource.createReservation(
        eventId: any(named: 'eventId'),
        quantity: any(named: 'quantity'),
        status: any(named: 'status'),
      ),
    ).thenAnswer((_) async => _tReservation());

    await repository.createReservation(
      eventId: 'evt-1',
      quantity: 1,
      initialStatus: ReservationStatus.pending,
    );

    // El pending retiene el cupo hasta que se verifique el pago.
    verify(
      () => datasource.createReservation(
        eventId: 'evt-1',
        quantity: 1,
        status: 'pending',
      ),
    ).called(1);
  });

  test('createReservation sin cupos llega como Failure', () async {
    when(
      () => datasource.createReservation(
        eventId: any(named: 'eventId'),
        quantity: any(named: 'quantity'),
        status: any(named: 'status'),
      ),
    ).thenThrow(const ValidationFailure('No hay cupos suficientes'));

    final Result<Reservation> result = await repository.createReservation(
      eventId: 'evt-1',
      quantity: 99,
      initialStatus: ReservationStatus.pending,
    );

    expect(
      (result as FailureResult<Reservation>).failure,
      isA<ValidationFailure>(),
    );
  });

  group('cancelPendingReservation', () {
    test('libera el cupo con el id que le dieron', () async {
      when(
        () => datasource.deletePendingReservation(id: any(named: 'id')),
      ).thenAnswer((_) async {});

      final Result<void> result = await repository.cancelPendingReservation(
        id: 'res-1',
      );

      expect(result, isA<Success<void>>());
      verify(
        () => datasource.deletePendingReservation(id: 'res-1'),
      ).called(1);
    });

    test('si el borrado falla lo reporta en vez de lanzar', () async {
      when(
        () => datasource.deletePendingReservation(id: any(named: 'id')),
      ).thenThrow(const ServerFailure());

      // Una excepción acá taparía el resultado del pago que se está informando.
      final Result<void> result = await repository.cancelPendingReservation(
        id: 'res-1',
      );

      expect((result as FailureResult<void>).failure, isA<ServerFailure>());
    });
  });

  group('getMyReservations', () {
    test('mapea la lista de modelos', () async {
      when(datasource.fetchMyReservations).thenAnswer(
        (_) async => <RemoteReservationModel>[_tReservation()],
      );

      final Result<List<Reservation>> result = await repository
          .getMyReservations();

      expect(result, isA<Success<List<Reservation>>>());
      expect((result as Success<List<Reservation>>).data, hasLength(1));
    });

    test('sin reservas devuelve lista vacía, no un error', () async {
      when(
        datasource.fetchMyReservations,
      ).thenAnswer((_) async => <RemoteReservationModel>[]);

      final Result<List<Reservation>> result = await repository
          .getMyReservations();

      expect((result as Success<List<Reservation>>).data, isEmpty);
    });

    test('una sesión expirada llega como Failure', () async {
      when(
        datasource.fetchMyReservations,
      ).thenThrow(const UnauthorizedFailure());

      final Result<List<Reservation>> result = await repository
          .getMyReservations();

      expect(
        (result as FailureResult<List<Reservation>>).failure,
        isA<UnauthorizedFailure>(),
      );
    });
  });
}
