import 'package:eventix/core/errors/map_supabase_error.dart';
import 'package:eventix/features/reservations/infrastructure/datasources/reservations_datasource.dart';
import 'package:eventix/features/reservations/infrastructure/models/remote_reservation_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseReservationsDatasource implements ReservationsDatasource {
  const SupabaseReservationsDatasource(this._client);

  final SupabaseClient _client;

  static const String _select = '*, events(title, starts_at)';

  Future<T> _guard<T>(Future<T> Function() fn) async {
    try {
      return await fn();
    } catch (e) {
      throw mapSupabaseError(e);
    }
  }

  @override
  Future<RemoteReservationModel> createReservation({
    required String eventId,
    required int quantity,
  }) => _guard(() async {
    final Map<String, dynamic> row = await _client
        .from('reservations')
        .insert(<String, dynamic>{
          'event_id': eventId,
          'quantity': quantity,
        })
        .select(_select)
        .single();
    return RemoteReservationModel.fromJson(row);
  });

  @override
  Future<List<RemoteReservationModel>> fetchMyReservations() =>
      _guard(() async {
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
