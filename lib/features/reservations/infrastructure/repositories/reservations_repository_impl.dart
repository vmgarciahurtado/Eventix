import 'package:eventix/core/helpers/execute_repository_call.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/reservations/domain/entities/reservation.dart';
import 'package:eventix/features/reservations/domain/entities/reservation_status.dart';
import 'package:eventix/features/reservations/domain/repositories/reservations_repository.dart';
import 'package:eventix/features/reservations/infrastructure/datasources/reservations_datasource.dart';
import 'package:eventix/features/reservations/infrastructure/mappers/reservation_mapper.dart';
import 'package:eventix/features/reservations/infrastructure/models/remote_reservation_model.dart';

class ReservationsRepositoryImpl implements ReservationsRepository {
  const ReservationsRepositoryImpl(this._datasource);

  final ReservationsDatasource _datasource;

  @override
  Future<Result<Reservation>> createReservation({
    required String eventId,
    required int quantity,
    required ReservationStatus initialStatus,
  }) => executeRepositoryCall(() async {
    final RemoteReservationModel model = await _datasource.createReservation(
      eventId: eventId,
      quantity: quantity,
      status: initialStatus.name,
    );
    return ReservationMapper.toEntity(model);
  });

  @override
  Future<Result<void>> cancelPendingReservation({required String id}) =>
      executeRepositoryCall(
        () => _datasource.deletePendingReservation(id: id),
      );

  @override
  Future<Result<List<Reservation>>> getMyReservations() =>
      executeRepositoryCall(() async {
        final List<RemoteReservationModel> models = await _datasource
            .fetchMyReservations();
        return models.map(ReservationMapper.toEntity).toList();
      });
}
