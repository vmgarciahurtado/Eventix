import 'package:eventix/features/events/domain/entities/category.dart';
import 'package:eventix/features/events/infrastructure/models/remote_category_model.dart';

abstract final class CategoryMapper {
  static Category toEntity(RemoteCategoryModel m) =>
      Category(id: m.id, name: m.name);
}
