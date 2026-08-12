import 'package:eventix/features/events/domain/entities/category.dart';
import 'package:eventix/features/events/infrastructure/models/remote_category_model.dart';

abstract final class CategoryMapper {
  static RemoteCategoryModel fromJson(Map<String, dynamic> json) {
    return RemoteCategoryModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      slug: json['slug'] as String,
    );
  }

  static Category toEntity(RemoteCategoryModel m) {
    return Category(id: m.id, name: m.name);
  }
}
