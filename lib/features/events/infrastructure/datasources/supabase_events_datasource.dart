import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/errors/supabase_guard.dart';
import 'package:eventix/features/events/domain/entities/event_filter.dart';
import 'package:eventix/features/events/infrastructure/datasources/events_datasource.dart';
import 'package:eventix/features/events/infrastructure/mappers/category_mapper.dart';
import 'package:eventix/features/events/infrastructure/mappers/city_mapper.dart';
import 'package:eventix/features/events/infrastructure/mappers/event_mapper.dart';
import 'package:eventix/features/events/infrastructure/models/remote_category_model.dart';
import 'package:eventix/features/events/infrastructure/models/remote_city_model.dart';
import 'package:eventix/features/events/infrastructure/models/remote_event_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseEventsDatasource implements EventsDatasource {
  const SupabaseEventsDatasource(this._client);

  final SupabaseClient _client;

  /// Incluye los nombres de categoría y ciudad mediante joins de Supabase.
  static const String _eventSelect = '*, categories(name), cities(name)';

  @override
  Future<List<RemoteEventModel>> fetchEvents(EventFilter filter) {
    return guardSupabaseCall(() async {
      PostgrestFilterBuilder<List<Map<String, dynamic>>> query = _client
          .from('events')
          .select(_eventSelect);

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
        // `starts_at` es timestamptz: la ventana del día local debe
        // serializarse en UTC o Postgres la interpreta corrida de zona.
        final DateTime start = DateTime(date.year, date.month, date.day);
        final DateTime end = start.add(const Duration(days: 1));
        query = query
            .gte('starts_at', start.toUtc().toIso8601String())
            .lt('starts_at', end.toUtc().toIso8601String());
      }

      final List<Map<String, dynamic>> rows = await query.order('starts_at');
      return rows
          .map((Map<String, dynamic> e) => EventMapper.fromJson(e))
          .toList();
    });
  }

  @override
  Future<RemoteEventModel> fetchEventById(String id) {
    return guardSupabaseCall(() async {
      final Map<String, dynamic>? row = await _client
          .from('events')
          .select(_eventSelect)
          .eq('id', id)
          .maybeSingle();
      if (row == null) throw const NotFoundFailure();
      return EventMapper.fromJson(row);
    });
  }

  @override
  Future<List<RemoteCategoryModel>> fetchCategories() {
    return guardSupabaseCall(() async {
      final List<Map<String, dynamic>> rows = await _client
          .from('categories')
          .select()
          .order('name');
      return rows
          .map((Map<String, dynamic> e) => CategoryMapper.fromJson(e))
          .toList();
    });
  }

  @override
  Future<int> fetchAvailableSpots(String eventId) {
    return guardSupabaseCall(() async {
      final Map<String, dynamic> row = await _client
          .from('event_availability')
          .select('available')
          .eq('event_id', eventId)
          .single();
      return (row['available'] as num).toInt();
    });
  }

  @override
  Future<List<RemoteCityModel>> fetchCities() {
    return guardSupabaseCall(() async {
      final List<Map<String, dynamic>> rows = await _client
          .from('cities')
          .select()
          .order('name');
      return rows
          .map((Map<String, dynamic> e) => CityMapper.fromJson(e))
          .toList();
    });
  }
}
