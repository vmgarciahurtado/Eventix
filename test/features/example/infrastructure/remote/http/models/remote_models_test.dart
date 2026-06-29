import 'package:eventix/features/example/infrastructure/remote/http/models/remote_example_model.dart';
import 'package:eventix/features/example/infrastructure/remote/http/models/remote_example_response.dart';
import 'package:eventix/features/example/infrastructure/remote/http/models/remote_shape_model.dart';
import 'package:eventix/features/example/infrastructure/remote/http/models/remote_shape_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RemoteExampleModel.fromJson', () {
    test(
      'given a valid JSON map when fromJson is called '
      'then all fields are parsed correctly',
      () {
        final RemoteExampleModel model =
            RemoteExampleModel.fromJson(_tExampleJson());

        expect(model.id, 1);
        expect(model.name, 'Test Example');
        expect(model.description, 'Test description');
      },
    );
  });

  group('RemoteExampleModel.toJson', () {
    test(
      'given a model when toJson is called '
      'then returns a map with all fields',
      () {
        const RemoteExampleModel model = RemoteExampleModel(
          id: 1,
          name: 'Test Example',
          description: 'Test description',
        );

        final Map<String, dynamic> json = model.toJson();

        expect(json['id'], 1);
        expect(json['name'], 'Test Example');
        expect(json['description'], 'Test description');
      },
    );
  });

  group('RemoteExampleResponse.fromJson', () {
    test(
      'given a valid JSON map when fromJson is called '
      'then results list is parsed correctly',
      () {
        final Map<String, dynamic> json = <String, dynamic>{
          'results': <Map<String, dynamic>>[_tExampleJson()],
        };

        final RemoteExampleResponse response =
            RemoteExampleResponse.fromJson(json);

        expect(response.results.length, 1);
        expect(response.results.first.id, 1);
        expect(response.results.first.name, 'Test Example');
      },
    );
  });

  group('RemoteShapeModel.fromJson', () {
    test(
      'given a valid JSON map when fromJson is called '
      'then all fields are parsed correctly',
      () {
        final RemoteShapeModel model = RemoteShapeModel.fromJson(_tShapeJson());

        expect(model.id, 2);
        expect(model.name, 'Circle');
        expect(model.description, 'A round shape');
      },
    );
  });

  group('RemoteShapeModel.toJson', () {
    test(
      'given a model when toJson is called '
      'then returns a map with all fields',
      () {
        const RemoteShapeModel model = RemoteShapeModel(
          id: 2,
          name: 'Circle',
          description: 'A round shape',
        );

        final Map<String, dynamic> json = model.toJson();

        expect(json['id'], 2);
        expect(json['name'], 'Circle');
        expect(json['description'], 'A round shape');
      },
    );
  });

  group('RemoteShapeResponse.fromJson', () {
    test(
      'given a valid JSON map when fromJson is called '
      'then results list is parsed correctly',
      () {
        final Map<String, dynamic> json = <String, dynamic>{
          'results': <Map<String, dynamic>>[_tShapeJson()],
        };

        final RemoteShapeResponse response =
            RemoteShapeResponse.fromJson(json);

        expect(response.results.length, 1);
        expect(response.results.first.id, 2);
        expect(response.results.first.name, 'Circle');
      },
    );
  });
}

Map<String, dynamic> _tExampleJson() => <String, dynamic>{
  'id': 1,
  'name': 'Test Example',
  'description': 'Test description',
};

Map<String, dynamic> _tShapeJson() => <String, dynamic>{
  'id': 2,
  'name': 'Circle',
  'description': 'A round shape',
};
