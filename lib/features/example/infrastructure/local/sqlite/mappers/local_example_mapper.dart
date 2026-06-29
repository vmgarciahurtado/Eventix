import 'package:eventix/features/example/domain/entities/example.dart';
import 'package:eventix/features/example/infrastructure/local/sqlite/models/local_example_model.dart';

class LocalExampleMapper {
  const LocalExampleMapper._();

  static Example toEntity(LocalExampleModel model) =>
      Example(id: model.id, name: model.name, description: model.description);

  static List<Example> toEntities(
    List<LocalExampleModel> models,
  ) => models.map((LocalExampleModel m) => toEntity(m)).toList();

  static LocalExampleModel toModel(Example entity) => LocalExampleModel(
    id: entity.id,
    name: entity.name,
    description: entity.description,
  );

  static List<LocalExampleModel> toModels(
    List<Example> entities,
  ) => entities.map((Example e) => toModel(e)).toList();
}
