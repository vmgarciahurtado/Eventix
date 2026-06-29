import 'package:eventix/core/services/sqlite/memory/in_memory_sqlite_service.dart';
import 'package:eventix/features/example/infrastructure/local/sqlite/datasource/sqlite_example_datasource.dart';
import 'package:eventix/features/example/infrastructure/local/sqlite/models/local_example_model.dart';
import 'package:eventix/features/example/infrastructure/local/sqlite/models/local_shape_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InMemorySqliteService sqliteService;
  late SqliteExampleDatasource datasource;

  setUp(() {
    sqliteService = InMemorySqliteService();
    datasource = SqliteExampleDatasource(sqliteService);
  });

  group('SqliteExampleDatasource.getExamples', () {
    test(
      'given an empty table when getExamples is called '
      'then returns an empty list',
      () async {
        final List<LocalExampleModel> result = await datasource.getExamples();

        expect(result, isEmpty);
      },
    );

    test(
      'given cached rows in the table when getExamples is called '
      'then returns the mapped LocalExampleModel list',
      () async {
        await sqliteService.insert(
          'examples',
          <Map<String, dynamic>>[_tLocalExampleJson()],
        );

        final List<LocalExampleModel> result = await datasource.getExamples();

        expect(result.length, 1);
        expect(result.first.id, 1);
        expect(result.first.name, 'Test Example');
        expect(result.first.description, 'Test description');
      },
    );
  });

  group('SqliteExampleDatasource.cacheExample', () {
    test(
      'given a list of LocalExampleModels when cacheExample is called '
      'then subsequent getExamples returns those models',
      () async {
        await datasource.cacheExample(<LocalExampleModel>[_tLocalExample()]);

        final List<LocalExampleModel> result = await datasource.getExamples();

        expect(result.length, 1);
        expect(result.first.id, 1);
        expect(result.first.name, 'Test Example');
      },
    );

    test(
      'given existing cached examples when cacheExample is called again '
      'then the old data is replaced by the new data',
      () async {
        await datasource.cacheExample(<LocalExampleModel>[_tLocalExample()]);
        await datasource.cacheExample(<LocalExampleModel>[
          const LocalExampleModel(
            id: 2,
            name: 'New Example',
            description: 'New',
          ),
        ]);

        final List<LocalExampleModel> result = await datasource.getExamples();

        expect(result.length, 1);
        expect(result.first.id, 2);
        expect(result.first.name, 'New Example');
      },
    );
  });

  group('SqliteExampleDatasource.clearExampleCache', () {
    test(
      'given cached examples when clearExampleCache is called '
      'then getExamples returns an empty list',
      () async {
        await datasource.cacheExample(<LocalExampleModel>[_tLocalExample()]);
        await datasource.clearExampleCache();

        final List<LocalExampleModel> result = await datasource.getExamples();

        expect(result, isEmpty);
      },
    );
  });

  group('SqliteExampleDatasource.getShapes', () {
    test(
      'given an empty table when getShapes is called '
      'then returns an empty list',
      () async {
        final List<LocalShapeModel> result = await datasource.getShapes();

        expect(result, isEmpty);
      },
    );

    test(
      'given cached rows in the table when getShapes is called '
      'then returns the mapped LocalShapeModel list',
      () async {
        await sqliteService.insert(
          'shapes',
          <Map<String, dynamic>>[_tLocalShapeJson()],
        );

        final List<LocalShapeModel> result = await datasource.getShapes();

        expect(result.length, 1);
        expect(result.first.id, 2);
        expect(result.first.name, 'Circle');
        expect(result.first.description, 'A round shape');
      },
    );
  });

  group('SqliteExampleDatasource.cacheShape', () {
    test(
      'given a list of LocalShapeModels when cacheShape is called '
      'then subsequent getShapes returns those models',
      () async {
        await datasource.cacheShape(<LocalShapeModel>[_tLocalShape()]);

        final List<LocalShapeModel> result = await datasource.getShapes();

        expect(result.length, 1);
        expect(result.first.id, 2);
        expect(result.first.name, 'Circle');
      },
    );

    test(
      'given existing cached shapes when cacheShape is called again '
      'then the old data is replaced by the new data',
      () async {
        await datasource.cacheShape(<LocalShapeModel>[_tLocalShape()]);
        await datasource.cacheShape(<LocalShapeModel>[
          const LocalShapeModel(
            id: 3,
            name: 'Square',
            description: 'Four sides',
          ),
        ]);

        final List<LocalShapeModel> result = await datasource.getShapes();

        expect(result.length, 1);
        expect(result.first.id, 3);
        expect(result.first.name, 'Square');
      },
    );
  });

  group('SqliteExampleDatasource.clearShapeCache', () {
    test(
      'given cached shapes when clearShapeCache is called '
      'then getShapes returns an empty list',
      () async {
        await datasource.cacheShape(<LocalShapeModel>[_tLocalShape()]);
        await datasource.clearShapeCache();

        final List<LocalShapeModel> result = await datasource.getShapes();

        expect(result, isEmpty);
      },
    );
  });
}

LocalExampleModel _tLocalExample() => const LocalExampleModel(
  id: 1,
  name: 'Test Example',
  description: 'Test description',
);

LocalShapeModel _tLocalShape() => const LocalShapeModel(
  id: 2,
  name: 'Circle',
  description: 'A round shape',
);

Map<String, dynamic> _tLocalExampleJson() => <String, dynamic>{
  'id': 1,
  'name': 'Test Example',
  'description': 'Test description',
};

Map<String, dynamic> _tLocalShapeJson() => <String, dynamic>{
  'id': 2,
  'name': 'Circle',
  'description': 'A round shape',
};
