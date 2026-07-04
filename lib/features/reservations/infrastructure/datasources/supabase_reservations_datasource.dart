import 'package:eventix/core/errors/supabase_guard.dart';
import 'package:eventix/features/reservations/infrastructure/datasources/reservations_datasource.dart';
import 'package:eventix/features/reservations/infrastructure/models/remote_reservation_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseReservationsDatasource implements ReservationsDatasource {
  const SupabaseReservationsDatasource(this._client);

  final SupabaseClient _client;

  static const String _select = '*, events(title, starts_at)';

  @override
  Future<RemoteReservationModel> createReservation({
    required String eventId,
    required int quantity,
    required String status,
  }) => guardSupabaseCall(() async {
    final Map<String, dynamic> row = await _client
        .from('reservations')
        .insert(<String, dynamic>{
          'event_id': eventId,
          'quantity': quantity,
          'status': status,
        })
        .select(_select)
        .single();
    return RemoteReservationModel.fromJson(row);
  });

  @override
  Future<void> deletePendingReservation({required String id}) =>
      guardSupabaseCall(
        () => _client.from('reservations').delete().eq('id', id),
      );

  @override
  Future<List<RemoteReservationModel>> fetchMyReservations() =>
      guardSupabaseCall(() async {
        final List<Map<String, dynamic>> rows = await _client
            .from('reservations')
            .select(_select)
            .order('created_at', ascending: false);
        return rows
            .map(
              (Map<String, dynamic> e) => RemoteReservationModel.fromJson(e),
            )
            .toList();
      });
}
