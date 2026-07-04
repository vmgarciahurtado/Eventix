import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/reservations/domain/repositories/reservations_repository.dart';

class CancelPendingReservation {
  const CancelPendingReservation(this._repository);

  final ReservationsRepository _repository;

  Future<Result<void>> call({required String id}) =>
      _repository.cancelPendingReservation(id: id);
}
