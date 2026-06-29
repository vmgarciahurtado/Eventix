import 'package:eventix/features/example/domain/entities/example.dart';
import 'package:eventix/features/example/domain/entities/shape.dart';
import 'package:eventix/features/example/infrastructure/local/sqlite/mappers/local_example_mapper.dart';
import 'package:eventix/features/example/infrastructure/local/sqlite/mappers/local_shape_mapper.dart';
import 'package:eventix/features/example/infrastructure/local/sqlite/models/local_example_model.dart';
import 'package:eventix/features/example/infrastructure/local/sqlite/models/local_shape_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalExampleMapper.toEntity', () {
    test(
      'given a LocalExampleModel when toEntity is called '
      'then returns an Example with matching fields',
      () {
        const LocalExampleModel model = LocalExampleModel(
          id: 1,
          name: 'Cached Example',
          description: 'Cached description',
        );

        final Example entity = LocalExampleMapper.toEntity(model);

        expect(entity.id, 1);
        expect(entity.name, 'Cached Example');
        expect(entity.description, 'Cached description');
      },
    );
  });

  group('LocalExampleMapper.toModel', () {
    test(
      'given an Example entity when toModel is called '
      'then returns a LocalExampleModel with matching fields',
      () {
        const Example entity = Example(
          id: 1,
          name: 'Cached Example',
          description: 'Cached description',
        );

        final LocalExampleModel model = LocalExampleMapper.toModel(entity);

        expect(model.id, 1);
        expect(model.name, 'Cached Example');
        expect(model.description, 'Cached description');
      },
    );
  });

  group('LocalExampleMapper.toEntities', () {
    test(
      'given a list of LocalExampleModels when toEntities is called '
      'then returns a list of Examples with matching length and fields',
      () {
        final List<LocalExampleModel> models = <LocalExampleModel>[
          const LocalExampleModel(id: 1, name: 'A', description: 'D1'),
          const LocalExampleModel(id: 2, name: 'B', description: 'D2'),
        ];

        final List<Example> entities = LocalExampleMapper.toEntities(models);

        expect(entities.length, 2);
        expect(entities.first.id, 1);
        expect(entities.last.id, 2);
      },
    );
  });

  group('LocalExampleMapper.toModels', () {
    test(
      'given a list of Example entities when toModels is called '
      'then returns a list of LocalExampleModels with matching length '
      'and fields',
      () {
        final List<Example> entities = <Example>[
          const Example(id: 1, name: 'A', description: 'D1'),
          const Example(id: 2, name: 'B', description: 'D2'),
        ];

        final List<LocalExampleModel> models =
            LocalExampleMapper.toModels(entities);

        expect(models.length, 2);
        expect(models.first.id, 1);
        expect(models.last.id, 2);
      },
    );
  });

  group('LocalShapeMapper.toEntity', () {
    test(
      'given a LocalShapeModel when toEntity is called '
      'then returns a Shape with matching fields',
      () {
        const LocalShapeModel model = LocalShapeModel(
          id: 2,
          name: 'Triangle',
          description: 'Three sides',
        );

        final Shape entity = LocalShapeMapper.toEntity(model);

        expect(entity.id, 2);
        expect(entity.name, 'Triangle');
        expect(entity.description, 'Three sides');
      },
    );
  });

  group('LocalShapeMapper.toModel', () {
    test(
      'given a Shape entity when toModel is called '
      'then returns a LocalShapeModel with matching fields',
      () {
        const Shape entity = Shape(
          id: 2,
          name: 'Triangle',
          description: 'Three sides',
        );

        final LocalShapeModel model = LocalShapeMapper.toModel(entity);

        expect(model.id, 2);
        expect(model.name, 'Triangle');
        expect(model.description, 'Three sides');
      },
    );
  });

  group('LocalShapeMapper.toEntities', () {
    test(
      'given a list of LocalShapeModels when toEntities is called '
      'then returns a list of Shapes with matching length and fields',
      () {
        final List<LocalShapeModel> models = <LocalShapeModel>[
          const LocalShapeModel(id: 1, name: 'Square', description: 'D1'),
          const LocalShapeModel(id: 2, name: 'Triangle', description: 'D2'),
        ];

        final List<Shape> entities = LocalShapeMapper.toEntities(models);

        expect(entities.length, 2);
        expect(entities.first.id, 1);
        expect(entities.last.id, 2);
      },
    );
  });

  group('LocalShapeMapper.toModels', () {
    test(
      'given a list of Shape entities when toModels is called '
      'then returns a list of LocalShapeModels with matching length '
      'and fields',
      () {
        final List<Shape> entities = <Shape>[
          const Shape(id: 1, name: 'Square', description: 'D1'),
          const Shape(id: 2, name: 'Triangle', description: 'D2'),
        ];

        final List<LocalShapeModel> models =
            LocalShapeMapper.toModels(entities);

        expect(models.length, 2);
        expect(models.first.id, 1);
        expect(models.last.id, 2);
      },
    );
  });
}
