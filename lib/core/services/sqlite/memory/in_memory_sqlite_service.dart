import 'package:eventix/core/services/sqlite/sqlite_service.dart';

/// Implementación en memoria de [SqliteService].
///
/// Simula las tablas de SQLite con mapas en memoria. Cuando se agregue la
/// dependencia real (sqflite/drift), basta con crear una nueva implementación
/// de [SqliteService] sin tocar los datasources que lo consumen.
class InMemorySqliteService implements SqliteService {
  final Map<String, List<Map<String, dynamic>>> _tables =
      <String, List<Map<String, dynamic>>>{};

  @override
  Future<List<Map<String, dynamic>>> query(String table) async =>
      List<Map<String, dynamic>>.unmodifiable(
        _tables[table] ?? const <Map<String, dynamic>>[],
      );

  @override
  Future<void> insert(String table, List<Map<String, dynamic>> rows) async {
    (_tables[table] ??= <Map<String, dynamic>>[]).addAll(rows);
  }

  @override
  Future<void> clear(String table) async => _tables[table]?.clear();
}