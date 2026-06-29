import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/reservations/domain/entities/reservation.dart';
import 'package:eventix/features/reservations/domain/repositories/reservations_repository.dart';

class CreateReservation {
  const CreateReservation(this._repository);

  final ReservationsRepository _repository;

  Future<Result<Reservation>> call({
    required String eventId,
    required int quantity,
  }) => _repository.createReservation(eventId: eventId, quantity: quantity);
}
