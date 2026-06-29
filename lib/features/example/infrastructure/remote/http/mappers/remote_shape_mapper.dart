import 'package:eventix/features/example/domain/entities/shape.dart';
import 'package:eventix/features/example/infrastructure/remote/http/models/remote_shape_model.dart';

class RemoteShapeMapper {
  const RemoteShapeMapper._();

  static Shape toEntity(RemoteShapeModel model) =>
      Shape(id: model.id, name: model.name, description: model.description);

  static List<Shape> toEntities(
    List<RemoteShapeModel> models,
  ) => models.map((RemoteShapeModel m) => toEntity(m)).toList();
}
