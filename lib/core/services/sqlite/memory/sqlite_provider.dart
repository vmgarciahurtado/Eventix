import 'package:eventix/core/services/sqlite/memory/in_memory_sqlite_service.dart';
import 'package:eventix/core/services/sqlite/sqlite_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<SqliteService> sqliteServiceProvider = Provider<SqliteService>(
  (Ref ref) => InMemorySqliteService(),
);
