import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/reservations/domain/entities/reservation.dart';
import 'package:eventix/features/reservations/domain/repositories/reservations_repository.dart';

class GetMyReservations {
  const GetMyReservations(this._repository);

  final ReservationsRepository _repository;

  Future<Result<List<Reservation>>> call() =>
      _repository.getMyReservations();
}
