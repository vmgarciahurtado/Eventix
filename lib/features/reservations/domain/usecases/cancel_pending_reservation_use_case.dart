import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/reservations/domain/repositories/reservations_repository.dart';

class CancelPendingReservationUseCase {
  const CancelPendingReservationUseCase(this._repository);

  final ReservationsRepository _repository;

  Future<Result<void>> call({required String id}) {
    return _repository.cancelPendingReservation(id: id);
  }
}
