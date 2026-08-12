import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/reservations/domain/entities/reservation.dart';
import 'package:eventix/features/reservations/domain/enums/reservation_status.dart';
import 'package:eventix/features/reservations/domain/repositories/reservations_repository.dart';

class CreateReservationUseCase {
  const CreateReservationUseCase(this._repository);

  final ReservationsRepository _repository;

  Future<Result<Reservation>> call({
    required String eventId,
    required int quantity,
    required ReservationStatus initialStatus,
  }) {
    return _repository.createReservation(
      eventId: eventId,
      quantity: quantity,
      initialStatus: initialStatus,
    );
  }
}
