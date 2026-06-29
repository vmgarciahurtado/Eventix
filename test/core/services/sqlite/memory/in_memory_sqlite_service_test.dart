import 'package:eventix/core/services/sqlite/memory/in_memory_sqlite_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InMemorySqliteService service;

  setUp(() {
    service = InMemorySqliteService();
  });

  group('InMemorySqliteService.query', () {
    test(
      'given an empty service '
      'when query is called on a non-existent table '
      'then returns an empty list',
      () async {
        final List<Map<String, dynamic>> result = await service.query('items');
        expect(result, isEmpty);
      },
    );

    test(
      'given rows inserted into a table '
      'when query is called '
      'then returns the inserted rows',
      () async {
        await service.insert('items', <Map<String, dynamic>>[_tRow()]);

        final List<Map<String, dynamic>> result = await service.query('items');

        expect(result.length, 1);
        expect(result.first['id'], 1);
        expect(result.first['name'], 'Test Item');
      },
    );

    test(
      'given rows in a table '
      'when query returns a list '
      'then the list is unmodifiable',
      () async {
        await service.insert('items', <Map<String, dynamic>>[_tRow()]);

        final List<Map<String, dynamic>> result = await service.query('items');

        expect(
          () => result.add(<String, dynamic>{'id': 99}),
          throwsA(isA<UnsupportedError>()),
        );
      },
    );
  });

  group('InMemorySqliteService.insert', () {
    test(
      'given a new table '
      'when insert is called '
      'then subsequent query returns the inserted rows',
      () async {
        await service.insert('products', <Map<String, dynamic>>[_tRow()]);

        final List<Map<String, dynamic>> result = await service.query(
          'products',
        );

        expect(result.length, 1);
      },
    );

    test(
      'given rows already in a table '
      'when insert is called again '
      'then the new rows are appended to the existing ones',
      () async {
        await service.insert('items', <Map<String, dynamic>>[_tRow()]);
        await service.insert('items', <Map<String, dynamic>>[_tRow(id: 2)]);

        final List<Map<String, dynamic>> result = await service.query('items');

        expect(result.length, 2);
        expect(result[0]['id'], 1);
        expect(result[1]['id'], 2);
      },
    );
  });

  group('InMemorySqliteService.clear', () {
    test(
      'given rows in a table '
      'when clear is called '
      'then subsequent query returns an empty list',
      () async {
        await service.insert('items', <Map<String, dynamic>>[_tRow()]);
        await service.clear('items');

        final List<Map<String, dynamic>> result = await service.query('items');

        expect(result, isEmpty);
      },
    );

    test(
      'given a non-existent table '
      'when clear is called '
      'then no error is thrown',
      () async {
        expect(
          () async => service.clear('non_existent_table'),
          returnsNormally,
        );
      },
    );
  });
}

Map<String, dynamic> _tRow({int id = 1}) => <String, dynamic>{
  'id': id,
  'name': 'Test Item',
};
