import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/errors/map_supabase_error.dart';
import 'package:eventix/features/events/domain/entities/event_filter.dart';
import 'package:eventix/features/events/infrastructure/datasources/events_datasource.dart';
import 'package:eventix/features/events/infrastructure/models/remote_category_model.dart';
import 'package:eventix/features/events/infrastructure/models/remote_city_model.dart';
import 'package:eventix/features/events/infrastructure/models/remote_event_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseEventsDatasource implements EventsDatasource {
  const SupabaseEventsDatasource(this._client);

  final SupabaseClient _client;

  /// Incluye los nombres de categoría y ciudad mediante joins de Supabase.
  static const String _eventSelect = '*, categories(name), cities(name)';

  Future<T> _guard<T>(Future<T> Function() fn) async {
    try {
      return await fn();
    } catch (e) {
      throw mapSupabaseError(e);
    }
  }

  @override
  Future<List<RemoteEventModel>> fetchEvents(EventFilter filter) =>
      _guard(() async {
        PostgrestFilterBuilder<List<Map<String, dynamic>>> query =
            _client.from('events').select(_eventSelect);

        final int? categoryId = filter.categoryId;
        final int? cityId = filter.cityId;
        final DateTime? date = filter.date;

        if (categoryId != null) {
          query = query.eq('category_id', categoryId);
        }
        if (cityId != null) {
          query = query.eq('city_id', cityId);
        }
        if (date != null) {
          final DateTime start = DateTime(date.year, date.month, date.day);
          final DateTime end = start.add(const Duration(days: 1));
          query = query
              .gte('starts_at', start.toIso8601String())
              .lt('starts_at', end.toIso8601String());
        }

        final List<Map<String, dynamic>> rows = await query.order('starts_at');
        return rows
            .map((Map<String, dynamic> e) => RemoteEventModel.fromJson(e))
            .toList();
      });

  @override
  Future<RemoteEventModel> fetchEventById(String id) => _guard(() async {
    final Map<String, dynamic>? row = await _client
        .from('events')
        .select(_eventSelect)
        .eq('id', id)
        .maybeSingle();
    if (row == null) throw const NotFoundFailure();
    return RemoteEventModel.fromJson(row);
  });

  @override
  Future<List<RemoteCategoryModel>> fetchCategories() => _guard(() async {
    final List<Map<String, dynamic>> rows = await _client
        .from('categories')
        .select()
        .order('name');
    return rows
        .map((Map<String, dynamic> e) => RemoteCategoryModel.fromJson(e))
        .toList();
  });

  @override
  Future<List<RemoteCityModel>> fetchCities() => _guard(() async {
    final List<Map<String, dynamic>> rows = await _client
        .from('cities')
        .select()
        .order('name');
    return rows
        .map((Map<String, dynamic> e) => RemoteCityModel.fromJson(e))
        .toList();
  });
}
