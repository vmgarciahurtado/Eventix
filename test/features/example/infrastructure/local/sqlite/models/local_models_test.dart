import 'package:eventix/features/example/infrastructure/local/sqlite/models/local_example_model.dart';
import 'package:eventix/features/example/infrastructure/local/sqlite/models/local_shape_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalExampleModel.fromJson', () {
    test(
      'given a valid JSON map when fromJson is called '
      'then all fields are parsed correctly',
      () {
        final LocalExampleModel model =
            LocalExampleModel.fromJson(_tLocalExampleJson());

        expect(model.id, 1);
        expect(model.name, 'Cached Example');
        expect(model.description, 'Cached description');
      },
    );
  });

  group('LocalExampleModel.toJson', () {
    test(
      'given a model when toJson is called '
      'then returns a map with all fields',
      () {
        const LocalExampleModel model = LocalExampleModel(
          id: 1,
          name: 'Cached Example',
          description: 'Cached description',
        );

        final Map<String, dynamic> json = model.toJson();

        expect(json['id'], 1);
        expect(json['name'], 'Cached Example');
        expect(json['description'], 'Cached description');
      },
    );
  });

  group('LocalExampleModel round-trip', () {
    test(
      'given a model when toJson then fromJson is called '
      'then the result matches the original model',
      () {
        const LocalExampleModel original = LocalExampleModel(
          id: 42,
          name: 'Round trip',
          description: 'Should survive',
        );

        final LocalExampleModel restored =
            LocalExampleModel.fromJson(original.toJson());

        expect(restored.id, original.id);
        expect(restored.name, original.name);
        expect(restored.description, original.description);
      },
    );
  });

  group('LocalShapeModel.fromJson', () {
    test(
      'given a valid JSON map when fromJson is called '
      'then all fields are parsed correctly',
      () {
        final LocalShapeModel model =
            LocalShapeModel.fromJson(_tLocalShapeJson());

        expect(model.id, 2);
        expect(model.name, 'Triangle');
        expect(model.description, 'Three sides');
      },
    );
  });

  group('LocalShapeModel.toJson', () {
    test(
      'given a model when toJson is called '
      'then returns a map with all fields',
      () {
        const LocalShapeModel model = LocalShapeModel(
          id: 2,
          name: 'Triangle',
          description: 'Three sides',
        );

        final Map<String, dynamic> json = model.toJson();

        expect(json['id'], 2);
        expect(json['name'], 'Triangle');
        expect(json['description'], 'Three sides');
      },
    );
  });

  group('LocalShapeModel round-trip', () {
    test(
      'given a model when toJson then fromJson is called '
      'then the result matches the original model',
      () {
        const LocalShapeModel original = LocalShapeModel(
          id: 99,
          name: 'Pentagon',
          description: 'Five sides',
        );

        final LocalShapeModel restored =
            LocalShapeModel.fromJson(original.toJson());

        expect(restored.id, original.id);
        expect(restored.name, original.name);
        expect(restored.description, original.description);
      },
    );
  });
}

Map<String, dynamic> _tLocalExampleJson() => <String, dynamic>{
  'id': 1,
  'name': 'Cached Example',
  'description': 'Cached description',
};

Map<String, dynamic> _tLocalShapeJson() => <String, dynamic>{
  'id': 2,
  'name': 'Triangle',
  'description': 'Three sides',
};
