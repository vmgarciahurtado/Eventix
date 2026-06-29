import 'package:eventix/features/events/domain/entities/category.dart';
import 'package:eventix/features/events/domain/entities/city.dart';
import 'package:eventix/features/events/domain/entities/event.dart';
import 'package:eventix/features/events/infrastructure/models/remote_category_model.dart';
import 'package:eventix/features/events/infrastructure/models/remote_city_model.dart';
import 'package:eventix/features/events/infrastructure/models/remote_event_model.dart';

abstract final class CategoryMapper {
  static Category toEntity(RemoteCategoryModel m) =>
      Category(id: m.id, name: m.name, slug: m.slug);
}

abstract final class CityMapper {
  static City toEntity(RemoteCityModel m) => City(id: m.id, name: m.name);
}

abstract final class EventMapper {
  static Event toEntity(RemoteEventModel m) => Event(
    id: m.id,
    title: m.title,
    description: m.description,
    categoryId: m.categoryId,
    cityId: m.cityId,
    categoryName: m.categoryName,
    cityName: m.cityName,
    startsAt: m.startsAt,
    price: m.price,
    capacity: m.capacity,
    imageKey: m.imageKey,
  );
}
