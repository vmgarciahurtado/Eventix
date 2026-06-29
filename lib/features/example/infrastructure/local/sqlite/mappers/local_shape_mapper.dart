import 'package:eventix/features/example/domain/entities/shape.dart';
import 'package:eventix/features/example/infrastructure/local/sqlite/models/local_shape_model.dart';

class LocalShapeMapper {
  const LocalShapeMapper._();

  static Shape toEntity(LocalShapeModel model) =>
      Shape(id: model.id, name: model.name, description: model.description);

  static List<Shape> toEntities(
    List<LocalShapeModel> models,
  ) => models.map((LocalShapeModel m) => toEntity(m)).toList();

  static LocalShapeModel toModel(Shape entity) => LocalShapeModel(
    id: entity.id,
    name: entity.name,
    description: entity.description,
  );

  static List<LocalShapeModel> toModels(
    List<Shape> entities,
  ) => entities.map((Shape e) => toModel(e)).toList();
}
