import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/reservations/domain/entities/reservation.dart';
import 'package:eventix/features/reservations/domain/enums/reservation_status.dart';
import 'package:eventix/features/reservations/domain/repositories/reservations_repository.dart';
import 'package:eventix/features/reservations/domain/usecases/cancel_pending_reservation.dart';
import 'package:eventix/features/reservations/domain/usecases/create_reservation.dart';
import 'package:eventix/features/reservations/domain/usecases/get_my_reservations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';

class _MockReservationsRepository extends Mock
    implements ReservationsRepository {}

/// Delegados de una línea. `StartPurchase` y `CompletePayment` orquestan y
/// viven aparte.
void main() {
  late _MockReservationsRepository repository;

  setUpAll(() => registerFallbackValue(ReservationStatus.pending));

  setUp(() => repository = _MockReservationsRepository());

  group('CreateReservation', () {
    test('entrega evento, cantidad y estado inicial', () async {
      when(
        () => repository.createReservation(
          eventId: any(named: 'eventId'),
          quantity: any(named: 'quantity'),
          initialStatus: any(named: 'initialStatus'),
        ),
      ).thenAnswer((_) async => Success<Reservation>(tReservation()));

      await CreateReservation(repository).call(
        eventId: 'evt-1',
        quantity: 3,
        initialStatus: ReservationStatus.pending,
      );

      // El estado inicial separa la reserva gratuita de la pagada.
      verify(
        () => repository.createReservation(
          eventId: 'evt-1',
          quantity: 3,
          initialStatus: ReservationStatus.pending,
        ),
      ).called(1);
    });

    test('quedarse sin cupos llega como Failure', () async {
      when(
        () => repository.createReservation(
          eventId: any(named: 'eventId'),
          quantity: any(named: 'quantity'),
          initialStatus: any(named: 'initialStatus'),
        ),
      ).thenAnswer(
        (_) async => const FailureResult<Reservation>(
          ValidationFailure('No hay cupos suficientes'),
        ),
      );

      expect(
        await CreateReservation(repository).call(
          eventId: 'evt-1',
          quantity: 99,
          initialStatus: ReservationStatus.pending,
        ),
        isA<FailureResult<Reservation>>(),
      );
    });
  });

  group('CancelPendingReservation', () {
    test('libera el cupo de la reserva que le dieron', () async {
      when(
        () => repository.cancelPendingReservation(id: any(named: 'id')),
      ).thenAnswer((_) async => const Success<void>(null));

      final Result<void> result = await CancelPendingReservation(
        repository,
      ).call(id: 'res-1');

      expect(result, isA<Success<void>>());
      // Con el id equivocado se liberaría la reserva de otra compra.
      verify(() => repository.cancelPendingReservation(id: 'res-1')).called(1);
    });

    test('un borrado fallido se reporta sin lanzar', () async {
      when(
        () => repository.cancelPendingReservation(id: any(named: 'id')),
      ).thenAnswer((_) async => const FailureResult<void>(ServerFailure()));

      expect(
        await CancelPendingReservation(repository).call(id: 'res-1'),
        isA<FailureResult<void>>(),
      );
    });
  });

  group('GetMyReservations', () {
    test('devuelve las reservas del repositorio', () async {
      when(repository.getMyReservations).thenAnswer(
        (_) async =>
            Success<List<Reservation>>(<Reservation>[tReservation()]),
      );

      final Result<List<Reservation>> result = await GetMyReservations(
        repository,
      ).call();

      expect((result as Success<List<Reservation>>).data, hasLength(1));
      verify(repository.getMyReservations).called(1);
    });

    test('una sesión expirada no se muestra como "sin reservas"', () async {
      when(repository.getMyReservations).thenAnswer(
        (_) async =>
            const FailureResult<List<Reservation>>(UnauthorizedFailure()),
      );

      expect(
        await GetMyReservations(repository).call(),
        isA<FailureResult<List<Reservation>>>(),
      );
    });
  });
}
