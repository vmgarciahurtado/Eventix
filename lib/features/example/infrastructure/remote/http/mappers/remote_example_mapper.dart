import 'package:eventix/features/example/domain/entities/example.dart';
import 'package:eventix/features/example/infrastructure/remote/http/models/remote_example_model.dart';

class RemoteExampleMapper {
  const RemoteExampleMapper._();

  static Example toEntity(RemoteExampleModel model) =>
      Example(id: model.id, name: model.name, description: model.description);

  static List<Example> toEntities(
    List<RemoteExampleModel> models,
  ) => models.map((RemoteExampleModel m) => toEntity(m)).toList();
}
