abstract interface class SqliteService {
  Future<List<Map<String, dynamic>>> query(String table);

  Future<void> insert(String table, List<Map<String, dynamic>> rows);

  Future<void> clear(String table);
}
