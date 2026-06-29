import 'package:eventix/features/example/domain/entities/example.dart';
import 'package:eventix/features/example/domain/entities/shape.dart';
import 'package:eventix/features/example/infrastructure/remote/http/mappers/remote_example_mapper.dart';
import 'package:eventix/features/example/infrastructure/remote/http/mappers/remote_shape_mapper.dart';
import 'package:eventix/features/example/infrastructure/remote/http/models/remote_example_model.dart';
import 'package:eventix/features/example/infrastructure/remote/http/models/remote_shape_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RemoteExampleMapper.toEntity', () {
    test(
      'given a RemoteExampleModel when toEntity is called '
      'then returns an Example with matching fields',
      () {
        const RemoteExampleModel model = RemoteExampleModel(
          id: 1,
          name: 'Test Example',
          description: 'Test description',
        );

        final Example entity = RemoteExampleMapper.toEntity(model);

        expect(entity.id, 1);
        expect(entity.name, 'Test Example');
        expect(entity.description, 'Test description');
      },
    );
  });

  group('RemoteExampleMapper.toEntities', () {
    test(
      'given a list of RemoteExampleModels when toEntities is called '
      'then returns a list of Examples with matching length and fields',
      () {
        final List<RemoteExampleModel> models = <RemoteExampleModel>[
          const RemoteExampleModel(id: 1, name: 'A', description: 'D1'),
          const RemoteExampleModel(id: 2, name: 'B', description: 'D2'),
        ];

        final List<Example> entities = RemoteExampleMapper.toEntities(models);

        expect(entities.length, 2);
        expect(entities.first.id, 1);
        expect(entities.last.id, 2);
      },
    );
  });

  group('RemoteShapeMapper.toEntity', () {
    test(
      'given a RemoteShapeModel when toEntity is called '
      'then returns a Shape with matching fields',
      () {
        const RemoteShapeModel model = RemoteShapeModel(
          id: 2,
          name: 'Circle',
          description: 'A round shape',
        );

        final Shape entity = RemoteShapeMapper.toEntity(model);

        expect(entity.id, 2);
        expect(entity.name, 'Circle');
        expect(entity.description, 'A round shape');
      },
    );
  });

  group('RemoteShapeMapper.toEntities', () {
    test(
      'given a list of RemoteShapeModels when toEntities is called '
      'then returns a list of Shapes with matching length and fields',
      () {
        final List<RemoteShapeModel> models = <RemoteShapeModel>[
          const RemoteShapeModel(id: 1, name: 'Square', description: 'D1'),
          const RemoteShapeModel(id: 2, name: 'Circle', description: 'D2'),
        ];

        final List<Shape> entities = RemoteShapeMapper.toEntities(models);

        expect(entities.length, 2);
        expect(entities.first.name, 'Square');
        expect(entities.last.name, 'Circle');
      },
    );
  });
}
